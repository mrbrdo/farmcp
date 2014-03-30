#= require jquery
#= require sugar

btc_value = null
use_btc_value = "btcde"
hashrate_mh = 4.85
single_rig = $("meta[name='single-rig']").attr('content') == 'true'

ip_regex = "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"

toDollars = (value, precision = 2)->
  if use_btc_value == "btcde"
    (hashrate_mh * value * btc_value[use_btc_value]).format(precision) + "€"
  else
    "$" + (hashrate_mh * value * btc_value[use_btc_value]).format(precision)

updateData = ->
  if single_rig
    $('#rig_overview').remove()
    $('#rig_pools').remove()

  $.getJSON "/data.json", (data)->
    btc_value = data.btc_value
    $('#btc_value h2.bitstamp').text("$#{btc_value.bitstamp.format(0)}")
    $('#btc_value h2.btcde').html("#{btc_value.btcde.format(0)}&euro;")

    appendBuzzwordsLi = ($ul, title, value)->
      $li = $("<li></li>")
      $li.append("<span class=\"label\">#{title}</span>")
      $li.append("<span class=\"value\">#{value}</span>")
      $li.appendTo($ul)

    # rig overview
    displayHashrate = (rate)->
      if rate < 1
        (rate * 1000).format(0) + " KH/s"
      else
        rate.format(2) + " MH/s"

    createTag = (tag, color, div)->
      $("<span class='tag'>#{tag}</span>").css('background-color', color).appendTo(div.find(".tags"))

    $('#rig_hashrate .change-rate').text('MH/s')

    if data.rig_info.length == 0
        $('#rig_hashrate .title').text(if single_rig then "Rig not found" else "No rigs found")
        $('#rig_hashrate .change-rate').text("")

    $('#rig_hashrate .value').text(data.rig_overview.mhs.format(2))
    
    unless single_rig
      $ul = $('#rig_overview ul').empty()
      appendBuzzwordsLi($ul, 'Temp - max', data.rig_overview.max_temp.format(0) + " °C")
      appendBuzzwordsLi($ul, 'Fan - max', data.rig_overview.max_fan_p.format(0) + "%")
      appendBuzzwordsLi($ul, '&nbsp;', '&nbsp;')
      appendBuzzwordsLi($ul, 'Temp - avg', data.rig_overview.temp.format(0) + " °C")
      appendBuzzwordsLi($ul, 'Fan - avg', data.rig_overview.fan_p.format(0) + "%")

      # pools
      pools = {}
      data.rig_info.each (rig)->
        pool = rig.pool.match(/\/\/(.+)/)?[1]
        if pool?
          pools[pool] ?= 0
          pools[pool] += rig.devs.sum (d)-> d.mhs
      pools_array = []
      Object.keys pools, (k, v)-> pools_array.push([k, v])
      pools_array.sortBy (v)-> -v[1]

      $ul = $('#rig_pools ul').empty()
      pools_array.first(5).each (pool)->
        appendBuzzwordsLi($ul, pool[0], pool[1].format(2) + " MH/s")

    # rigs
    $("div[id*=rig_info_]").remove()
    row = 2
    col = 0
    rigIdx = 0
    data.rig_info.each (rig)->
      rigIdx += 1
      col += 1
      if col > 4
        row += 1
        col = 1
      $div = $("<div id='rig_info_#{rigIdx}' class='square-1 purple-square'></div>")
      $div.append("<h1 class='rig_title'></h1>")
      $pool_info = $("<div class='pool_info'></div>")
      $pool_info.append("<h3 class='pool'></h3>")
      $pool_info.append("<span class='tags'></span>")
      $div.append($pool_info)
      $ul = $("<ul class='list-nostyle'></ul>")
      total_hashrate = 0
      rig.devs.each (dev, idx)->
        total_hashrate += dev.mhs

        $li = appendBuzzwordsLi($ul, "GPU ##{idx + 1}", displayHashrate(dev.mhs))
        if dev.mhs == 0
          $li.addClass("zero_hash_warning")
        else if dev.low_hash
          $li.addClass("low_hash_warning")

        reject_p = (100 * dev.rejected / dev.accepted).format(1)
        line = ""
        line += "F: #{dev.fan_p}%" unless single_rig
        line += " T: #{dev.temp} °C" unless single_rig
        $info_li = appendBuzzwordsLi($ul, "A: #{dev.accepted} R: #{reject_p}%" , line)
        $info_li.css("font-size", "15px")

      # this won't show the exception message when on link (/rig/moo) - that's intentional
      rig_name = if single_rig then rig.link else (rig.name ? (if rig.host.match(ip_regex) then "Rig ##{rigIdx}" else rig.host))
      $title = $div.find("h1.rig_title")
      $title.addClass("small") if rig_name.length > 6
      $title.text("#{rig_name} - #{displayHashrate(total_hashrate)}")

      stripped_pool = if rig.pool.split(':')[1]?
        rig.pool.split(':')[1].replace(/^\/\//, '')
      else
        ""
      $div.find("h3.pool").text(stripped_pool)

      if rig.beta_id
        color = if stripped_pool.indexOf('betarigs.com') == -1 then '#999' else 'violet'
        tag = "<a href='https://www.betarigs.com/rig/#{rig.beta_id}' target=_new>β-rigs</a>"
        createTag(tag, color, $div)

      unless single_rig
        rig.tags?.each (tag) ->
          if tag != ""
            color = if tag.match(/^\d+.?$/)
              '#47bbb3'
            else if tag.indexOf(':') != -1
              [tag, color] = tag.split(':')
              color
            else
              '#8699d5'
            createTag(tag, color, $div)

      $ul.appendTo($div)
      $('#dashboard').append($div)

setInterval(updateData, 30000)
updateData()

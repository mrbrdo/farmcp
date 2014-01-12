$ ->
  btc_value = null
  hashrate_mh = 4.85

  toDollars = (value, precision = 2)->
    "$" + (hashrate_mh * value * btc_value).format(precision)

  updateData = ->
    $.getJSON '/coins.json', (data)->
      btc_value = data.btc_value
      $('#btc_value h2').text("$#{btc_value.format(0)}")

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

      $('#rig_hashrate .value').text(data.rig_overview.mhs.format(2))
      $('#rig_hashrate .change-rate').text('MH/s')
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
        $li = $("<li data-row='#{row}' data-col='#{col}' data-sizex='1' data-sizey='1' class='gs_w'></li>")
        $div = $("<div id='rig_info_#{rigIdx}' class='widget widget-list buzzwords'></div>")
        $div.appendTo($li)
        $div.append("<h1 class='title'>Rig ##{rigIdx}</h1>")
        $ul = $("<ul class='list-nostyle'></ul>")
        total_hashrate = 0
        rig.devs.each (dev, idx)->
          total_hashrate += dev.mhs
          appendBuzzwordsLi($ul, "GPU ##{idx + 1}", displayHashrate(dev.mhs))
          reject_p = (100 * dev.rejected / dev.accepted).format(1)
          $info_li = appendBuzzwordsLi($ul, "A: #{dev.accepted} R: #{reject_p}%" , "F: #{dev.fan_p}% T: #{dev.temp} °C")
          $info_li.css("font-size", "15px")
        $div.find("h1").text("Rig ##{rigIdx} - " + displayHashrate(total_hashrate))
        $ul.appendTo($div)
        $('.gridster > ul').append($li)


  setInterval(updateData, 30000)
  updateData()

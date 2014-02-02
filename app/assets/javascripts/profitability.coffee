if $('#profitability_calculator_form').length > 0
  parseFloatField = (selector)->
    parseFloat($(selector).val().replace(/,/g, ''))

  calculateProfit = (price, diff, reward, hashrate)->
    btc_price = parseFloatField('#profitability_calculator_form input[name=btc_value]')
    profit = price * reward * 86400 / (diff * Math.pow(2, 32) / (hashrate * 1000))
    text = "<b>Revenue each day:</b><br>"
    text += "#{profit.format(5)} BTC<br>"
    text += "$" + (btc_price * profit).format(2)
    $('.profit_result').empty()
      .append("<div class='alert-box notice' style='font-size: 18px'>#{text}</div>")

  $('#profitability_calculator_form').submit (e)->
    e.preventDefault()
    $form = $(e.currentTarget)

    price = parseFloatField('#profitability_calculator_form input[name=price]')
    hashrate = parseFloatField('#profitability_calculator_form input[name=hashrate]')

    if $('#profitability_calculator_form input[name=diff]').val() == ""
      $.get '/profitability/pool_data', $form.serialize(), (data)->
        $('#profitability_calculator_form input[name=diff]').val(data.diff)
        $('#profitability_calculator_form input[name=reward]').val(data.reward)
        calculateProfit(price, data.diff, data.reward, hashrate)
    else
      diff = parseFloatField('#profitability_calculator_form input[name=diff]')
      reward = parseFloatField('#profitability_calculator_form input[name=reward]')
      calculateProfit(price, diff, reward, hashrate)

    true

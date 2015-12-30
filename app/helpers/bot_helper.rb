module BotHelper

#include <cstdlib>


def updateOrders(market)

    minAmountToConsider = 187
    
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    orders = api.currency_market_orders market

    purchase = orders["purchase"]
    sale = orders["sale"]

    secSale = 1000
    lSale = 1000
    hBuy = 0
    secBuy = 0

    sale.each do |p|
      price = Float(p["ppc"])
      amount = Integer(p["amount"])
      if (lSale > price && amount >= minAmountToConsider)
        lSale = price
      end
      if (secSale > price && price > lSale && amount >= minAmountToConsider)
        secSale = price
      end

    end


    purchase.each do |p|
      price = Float(p["ppc"])
      amount = Integer(p["amount"])
      if (hBuy < price && amount >= minAmountToConsider)
        hBuy = price
      end

      if (secBuy < price && price < hBuy && amount >= minAmountToConsider)
        secBuy = price
      end
    end

    spread = lSale - hBuy
    return lSale, hBuy, secSale, secBuy
    
  end

  def keepSelling(market, amount)
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    remaining = amount
    orderID = 0
    ourPrice = 1.0
    while (remaining > 0)
      lSale = updateOrders market
      if (ourPrice > lSale)
        ourPrice = lSale - 0.00000001
        api.revoke_order orderID
        orderID = sell market,remaining,ourPrice
        puts ourPrice
      end  
      remaining = checkRemaining market, orderID
      puts remaining
    end
  end

  def buyAndSell(market, buyAmount, sellAmount)
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
      
    updatedOrders = updateOrders market
    maxBuy = 0.000395 #updatedOrders[0]
    minSale = 0.000398 #updatedOrders[1]
    lSale = 100.0
    hBuy = 0.0000001

    puts "Starting trading with minSale: #{minSale} and MaxBuy: #{maxBuy}"

    remainingSell = sellAmount
    remainingBuy = buyAmount
    orderIDSell = 0
    orderIDBuy = 0
    ourSellPrice = 1.0
    ourBuyPrice = 0.0000001
    profit = 0.0
    while (remainingSell + remainingBuy > 500 && lSale > minSale && hBuy < maxBuy)
      
      updatedOrders = updateOrders market
      lSale = updatedOrders[0]
      hBuy = updatedOrders[1]
      secSale = updatedOrders[2]
      secBuy = updatedOrders[3]

      sellDiff = (ourSellPrice - lSale).abs
      buyDiff = (ourBuyPrice - hBuy).abs
      secSellDiff = (ourSellPrice - secSale).abs
      secBuyDiff = (ourBuyPrice - secBuy).abs

      puts "ls: #{lSale} hb: #{hBuy} 2s: #{secSale} 2b: #{secBuy}"
      puts "sellDiff #{sellDiff} buyDiff #{buyDiff}"
      puts "secSellDiff #{secSellDiff} and secBuyDiff #{secBuyDiff}"

      if ((sellDiff > 0.00000001 || secSellDiff > 0.00000001) && remainingSell > 200)
        api.revoke_order orderIDSell
        updatedOrders = updateOrders market
        lSale = updatedOrders[0]
        ourSellPrice = lSale - 0.00000001
        orderIDSell = sell market,remainingSell,ourSellPrice
        puts "New sell price: #{ourSellPrice}"
      end
      if ((buyDiff > 0.00000001 || secBuyDiff > 0.00000001) && remainingBuy > 200)
        api.revoke_order orderIDBuy
        updatedOrders = updateOrders market
        hBuy = updatedOrders[1]
        ourBuyPrice = hBuy + 0.00000001
        orderIDBuy = buy market,remainingBuy,ourBuyPrice
        puts "New buy price: #{ourBuyPrice}"
      end




      newRemaingSell = checkRemaining market, orderIDSell
      newRemaningBuy = checkRemaining market, orderIDBuy

      profit = profit + (remainingSell - newRemaingSell) * ourSellPrice - (remainingBuy - newRemaningBuy) * ourBuyPrice

      remainingSell = newRemaingSell
      remainingBuy = newRemaningBuy
      puts "Remaining buy #{remainingBuy}"
      puts "Remaining sale #{remainingSell}"
      puts "Spread #{ourSellPrice - ourBuyPrice}"
      puts "Profit #{profit}"
    end
  end


  def sell(market, amount, price)
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    newOrder = api.trade market, "sale", amount, price
    newOrderID = newOrder["id"]
  end

  def buy(market, amount, price)
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    newOrder = api.trade market, "purchase", amount, price
    newOrderID = newOrder["id"]
  end

  def checkRemaining(market, orderID)
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    orders = api.order_active market
    remaining = 0
    orders.each do |p|
      amount = Integer(p["amount"])
      if (Integer(p["id"]) == orderID)
        remaining = amount
      end
    end
    remaining
  end




  def revokeSale(market)
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    orders = api.order_active market
    cancelID = 0
    lSale = 1000
    orders.each do |p|
      price = Float(p["ppc"])
      category = (p["category"])
      if (lSale > price && category == "sale")
        lSale = price
        cancelID = Integer(p["id"])
      end
  end
  puts api.revoke_order cancelID
end


end

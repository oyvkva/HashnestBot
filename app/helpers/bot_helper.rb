module BotHelper

#include <cstdlib>


def updateOrders(market, minBuy, minSale)

    minSaleAmountToConsider = minSale
    minBuyAmountToConsider = minBuy
    
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
      if (lSale > price && amount >= minSaleAmountToConsider)
        lSale = price
      end
      if (secSale > price && price > lSale && amount >= minSaleAmountToConsider)
        secSale = price
      end

    end


    purchase.each do |p|
      price = Float(p["ppc"])
      amount = Integer(p["amount"])
      if (hBuy < price && amount >= minBuyAmountToConsider)
        hBuy = price
      end

      if (secBuy < price && price < hBuy && amount >= minBuyAmountToConsider)
        secBuy = price
      end
    end

    spread = lSale - hBuy
    return lSale, hBuy, secSale, secBuy
    
  end


  def buyAndSell(market, buyAmount, sellAmount)

    minBuy = 670
    minSale = 175
    maxBuy = 0.000379
    minSale = 0.000386


    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
      
    updatedOrders = updateOrders market,minBuy,minSale

    lSale = 100.0
    hBuy = 0.0000001
    bought = 0

    puts "Starting trading with minSale: #{minSale} and MaxBuy: #{maxBuy}"

    origSell = sellAmount
    origBuy = buyAmount
    newRemSell = sellAmount
    newRemBuy = buyAmount
    remSell = newRemSell
    remBuy = newRemBuy
    orderIDSell = 0
    orderIDBuy = 0
    ourSellPrice = 1.0
    ourBuyPrice = 0.0000001
    totalBuy = 0
    totalSell = 0
    while (2 > 0)

      # Setting remaining to what was remaining end of last loop
      remSell = newRemSell
      remBuy = newRemBuy

      
      updatedOrders = updateOrders market,minBuy,minSale
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

        if ((sellDiff > 0.00000001 || secSellDiff > 0.00000001) && remSell > minSale && lSale > minSale)
          api.revoke_order orderIDSell
          updatedOrders = updateOrders market,minBuy,minSale
          lSale = updatedOrders[0]
          if (lSale > minSale)
            ourSellPrice = lSale - 0.00000001
            orderIDSell = sell market,remSell,ourSellPrice
            puts "New sell price: #{ourSellPrice}"
          end
          
        end
        if ((buyDiff > 0.00000001 || secBuyDiff > 0.00000001) && remBuy > minBuy && hBuy < maxBuy)
          api.revoke_order orderIDBuy
          updatedOrders = updateOrders market,minBuy,minSale
          hBuy = updatedOrders[1]
          if (hBuy < maxBuy)
            ourBuyPrice = hBuy + 0.00000001
            orderIDBuy = buy market,remBuy,ourBuyPrice
            puts "New buy price: #{ourBuyPrice}"
          end
          
        end


      newRemSell = checkRemaining market, orderIDSell
      newRemBuy = checkRemaining market, orderIDBuy

      newBuy = (remBuy - newRemBuy)
      newSell = (remSell - newRemSell)

      totalBuy = totalBuy + newBuy
      totalSell = totalSell + newSell

      newRemSell = newRemSell #newBuy # Add newBuy if we want to sell what we buy
      newRemBuy = newRemBuy #newSell # Add newSell if we want to buy back what we sell

      puts "Remaining buy #{remBuy} total bought: #{totalBuy}"
      puts "Remaining sale #{remSell} total sold: #{totalSell}"
      puts "Spread #{ourSellPrice - ourBuyPrice}"
    
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



# Starts buying and selling
def startTrading #market, hashLeft, btcLeft

    @api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")

    market = 19
    hashLeft = 0
    btcLeft = 2.95

    minBuyAmount = 22
    minSaleAmount = 22
    maxBuy = 0.000399
    minSale = 0.000386

    sellInfo = [0,1000]
    buyInfo = [0,0.000001]


    puts "Starting trading with minSale: #{minSale} and MaxBuy: #{maxBuy}"

    while (1 > 0)

      #Check if we should buy or sell
      
      updatedOrders = updateOrders market,minBuyAmount,minSaleAmount
      lSale = updatedOrders[0]
      hBuy = updatedOrders[1]
      secSale = updatedOrders[2]
      secBuy = updatedOrders[3]


      if (lSale > minSale)
        #Price is good to sell

        #Check how much we can sell
        hashBal = hashBalance market
        sellAmount = hashBal[0] - hashLeft
        puts "We can sell #{sellAmount}"
        #If this is larger than 0, lets go on
        if (sellAmount > 0)
          #Check if we're already selling the right amount
          if (hashBal[1] == sellAmount)
            puts "We are selling the right amount"
            #Check if the price is right
            sellDiff = (sellInfo[1] - lSale).abs
            secSellDiff = (sellInfo[1] - secSale).abs
            puts "sellDiff #{sellDiff} sec #{secSellDiff}"
            if (sellDiff > 0.00000001 || secSellDiff > 0.00000001)
              puts "Sell Price is wrong, changing price..."
              sellInfo = revokeAndPlaceNewSell market, minBuyAmount, minSaleAmount, minSale, sellInfo[0], sellAmount
            end
          

          else
            puts "Cancelling and placing new sell order"
            sellInfo = revokeAndPlaceNewSell market, minBuyAmount, minSaleAmount, minSale, sellInfo[0], sellAmount
          end

        end
      else
        #We can't sell
      end


      if (hBuy < maxBuy)
        #Price is good to buy

        #Check how much we can buy
        btcBal = btcBalance
        buyBtc = btcBal[0] - btcLeft
        buyAmount = (buyBtc / hBuy).round
        puts "We can buy for #{buyBtc} btc - about #{buyAmount} hash, locked: #{btcBal[1]}"

        #If this is larger than 0, lets go on
        if (buyAmount > 0)

          #Check if we're already buying the right amount
          if ((btcBal[1] - buyBtc).abs < 0.1 )
            puts "We are selling the right amount"

            #Check if the price is right
            buyDiff = (buyInfo[1] - hBuy).abs
            secBuyDiff = (buyInfo[1]- secBuy).abs

            puts "BuyDiff #{buyDiff} sec #{secBuyDiff}"
            if (buyDiff > 0.00000001 || secBuyDiff > 0.00000001)
              puts "Buy Price is wrong, changing price..."
              buyInfo = revokeAndPlaceNewBuy market, minBuyAmount, minSaleAmount, maxBuy, buyInfo[0], buyAmount
            end


          else
            puts "Cancelling and placing new buy order"
            buyInfo = revokeAndPlaceNewBuy market, minBuyAmount, minSaleAmount, maxBuy, buyInfo[0], buyAmount
          end


        end


      else
        #We can't buy
      end

      puts "Last order sell #{sellInfo[0]} for #{sellInfo[1]} and buy #{buyInfo[0]} for #{buyInfo[1]}"
    end
  end


  def revokeAndPlaceNewSell(market, minBuyAmount, minSaleAmount, minSale, lastOrderIDSell, sellAmount)
    @api.revoke_order lastOrderIDSell
    orderIDSell = 0
    ourSellPrice = 1000
    updatedOrders = updateOrders market,minBuyAmount,minSaleAmount
    lSale = updatedOrders[0]
    if (lSale > minSale)
      ourSellPrice = lSale - 0.00000001
      orderIDSell = sell market,sellAmount,ourSellPrice
    end
    return orderIDSell, ourSellPrice
  end

  def revokeAndPlaceNewBuy(market, minBuyAmount, minSaleAmount, maxBuy, lastOrderIDBuy, buyAmount)
    @api.revoke_order lastOrderIDBuy
    orderIDBuy = 0
    ourBuyPrice = 0.0000001
    updatedOrders = updateOrders market,minBuyAmount,minSaleAmount
    hBuy = updatedOrders[1]
    if (hBuy < maxBuy)
      ourBuyPrice = hBuy + 0.00000001
      orderIDBuy = buy market,buyAmount,ourBuyPrice
    end
    return orderIDBuy, ourBuyPrice
  end




  def hashBalance(market)
    marketNames = {"18"=>"AntS4", "19"=>"AntS5", "20"=>"AntS7"}
    accounts = @api.hash_accounts
    amount = 0.0
    blocked = 0.0
    accounts.each do |p|
      if (String(p["currency"]["code"]) == marketNames["#{market}"])
        amount = Float(p["total"])
        blocked = Float(p["blocked"])
      end
    end
    return amount,blocked
  end

  def btcBalance
    balances = @api.currency_accounts
    amount = 0.0
    blocked = 0.0
    balances.each do |p|
      if (String(p["currency"]["code"]) =="btc")
        amount = Float(p["total"])
        blocked = Float(p["blocked"])
      end
    end
    return amount,blocked
  end

  def sell(market, amount, price)
    newOrder = @api.trade market, "sale", amount, price
    newOrderID = newOrder["id"] # Is nil if order didn't go through
  end

  def buy(market, amount, price)
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    newOrder = api.trade market, "purchase", amount, price
    newOrderID = newOrder["id"] # Is nil if order didn't go through
  end

  def checkRemaining(market, orderID)
    orders = @api.order_active market
    remaining = 0
    orders.each do |p|
      amount = Integer(p["amount"])
      if (Integer(p["id"]) == orderID)
        remaining = amount
      end
    end
    remaining
  end



  # Not used methods
  def revokeLowestSale(market)
    orders = @api.order_active market
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

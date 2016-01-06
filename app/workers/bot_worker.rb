class BotWorker
  include Sidekiq::Worker

  def perform market,hashLeft,btcLeft,tradingPrice
      startTrading(market,hashLeft,btcLeft,tradingPrice)
  end


# Starts buying and selling
def startTrading market,hashLeft,btcLeft,tradingPrice

    startID = Pricepoint.last.id

    #Set these:

    username = "whateverYourNameIS"
    hashKey =  "YourKeyHereLotsOfNUmbers"
    hashSecret = "YourSecretHereLooksSimilar" 

    @api = Hashnest::API.new(username, hashKey, hashSecret)
  
    market = 19 #change this for other market
    origHashLeft = hashLeft
    origBtcLeft = btcLeft

    @api.quick_revoke market, "sale"
    @api.quick_revoke market, "purchase"


    minBuyAmount = 200
    minSaleAmount = 200
    sellMin = tradingPrice
    buyMax = tradingPrice

    sellSpread = 0.00005
    buySpread = 0.00004


    middle = (sellMin + buyMax) / 2.0

    minOrder = 93

    btcLeft = origBtcLeft
    hashLeft = origHashLeft

    
    updatedOrders = updateOrders market,minBuyAmount,minSaleAmount
    lSale = updatedOrders[0]
    hBuy = updatedOrders[1]
    sellInfo = [0,lSale]
    buyInfo = [0,hBuy]

    #Check initial sell and buy
    hashBal = hashBalance market
    sellAmount = hashBal[0] - hashLeft

    btcBal = btcBalance
    buyBtc = btcBal[0] - btcLeft
    buyAmount = (buyBtc / buyMax).round

    puts "####### Starting trading Middle: #{middle} - Buying: #{buyAmount} - Selling: #{sellAmount} #######"

    while (Pricepoint.last.id <= startID)
      #Check if we should buy or sell
      
      updatedOrders = updateOrders market,minBuyAmount,minSaleAmount
      lSale = updatedOrders[0]
      hBuy = updatedOrders[1]
      secSale = updatedOrders[2]
      secBuy = updatedOrders[3]

      if (lSale > sellMin)
        #Price is good to sell

        if (minSaleAmount > minOrder)
          minSaleAmount = minSaleAmount * 0.9
        end


        #Check how much we can sell
        hashBal = hashBalance market
        sellAmount = hashBal[0] - hashLeft
        #If this is larger than 0, lets go on

        if (sellAmount > minOrder)
          #Check if we're already selling the right amount
          if ((hashBal[1] - sellAmount).abs < 50)
            #Check if the price is right
            sellDiff = (sellInfo[1] - lSale).abs
            secSellDiff = (sellInfo[1] - secSale).abs
            if (sellDiff > 0.000000009 || secSellDiff > 0.000000011)
              puts "Sell Price is wrong, changing price..."
              sellInfo = revokeAndPlaceNewSell market, minBuyAmount, minSaleAmount, sellMin, sellAmount
            end
          

          else
            puts "Cancelling and placing new sell order"
            sellInfo = revokeAndPlaceNewSell market, minBuyAmount, minSaleAmount, sellMin, sellAmount
          end
        else
          puts "Hashamount is #{sellAmount}, we can't sell less than #{minOrder}"
        end
      else
        puts "Lowest sell: #{lSale}, our min price: #{sellMin} = We can't sell!"
        if ((minSaleAmount * 1.2) < sellAmount)
          minSaleAmount = minSaleAmount * 1.2
        end
        sellInfo = [0,lSale]
      end


      if (hBuy < buyMax)
        #Price is good to buy
        if (minBuyAmount > minOrder)
          minBuyAmount = minBuyAmount * 0.95
        end

        #Check how much we can buy
        btcBal = btcBalance
        buyBtc = btcBal[0] - btcLeft
        buyAmount = (buyBtc / hBuy).round

        #If this is larger than 0, lets go on
        if (buyAmount > minOrder)

          #Check if we're already buying the right amount
          if ((btcBal[1] - buyBtc).abs < 0.1 )
            puts "We are buying the right amount"

            #Check if the price is right
            buyDiff = (buyInfo[1] - hBuy).abs
            secBuyDiff = (buyInfo[1]- secBuy).abs

            #puts "BuyDiff #{buyDiff} sec #{secBuyDiff}"
            if (buyDiff > 0.000000009 || secBuyDiff > 0.000000011)
              puts "Buy Price is wrong, changing price..."
              buyInfo = revokeAndPlaceNewBuy market, minBuyAmount, minSaleAmount, buyMax, buyAmount
            end


          else
            puts "Cancelling and placing new buy order"
            buyInfo = revokeAndPlaceNewBuy market, minBuyAmount, minSaleAmount, buyMax, buyAmount
          end

        else
          puts "Hashamout is #{buyAmount}, we can't buy less than #{minOrder} hash"
        end


      else
        puts "Highest buy: #{hBuy}, our max price: #{buyMax} = We can't buy!"
        if ((minBuyAmount * 1.2) < buyAmount)
          minBuyAmount = minBuyAmount * 1.2
        end
        buyInfo = [0,hBuy]
      end

      puts "Last order sell #{sellInfo[0]} for #{sellInfo[1]} and buy #{buyInfo[0]} for #{buyInfo[1]}"
      

      distanceToBuy = buyMax - buyInfo[1]
      btcLeft = origBtcLeft * (1 - distanceToBuy/buySpread)
      if btcLeft < 0.0
        btcLeft = 0.0
      end

      distanceToSell = sellInfo[1] - sellMin
      hashLeft = origHashLeft * (1 - distanceToSell/sellSpread)
      if hashLeft < 0.0
        hashLeft = 0.0
      end


      puts "Buy distance from middle: #{distanceToBuy*100000}, new btcLeft: #{btcLeft}, new minBuyAmount #{minBuyAmount}"
      puts "Sell distance from middle: #{distanceToSell*100000}, new hashLeft: #{hashLeft}, new minSaleAmount #{minSaleAmount}"

      total = totalBtcValue market,hBuy
      puts "####### Total now: #{total} #######"

    end
  end




def updateOrders(market, minBuy, minSale)

    minSaleAmountToConsider = minSale
    minBuyAmountToConsider = minBuy
    
    orders = @api.currency_market_orders market

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








  def revokeAndPlaceNewSell(market, minBuyAmount, minSaleAmount, minSale, sellAmount)
    @api.quick_revoke market, "sale"
    orderIDSell = 0
    ourSellPrice = minSale
    updatedOrders = updateOrders market,minBuyAmount,minSaleAmount
    lSale = updatedOrders[0]
    if (lSale > minSale)
      ourSellPrice = lSale - 0.00000001
      orderIDSell = sell market,sellAmount,ourSellPrice
    end
    return orderIDSell, ourSellPrice
  end

  def revokeAndPlaceNewBuy(market, minBuyAmount, minSaleAmount, maxBuy, buyAmount)
    @api.quick_revoke market, "purchase"
    orderIDBuy = 0
    ourBuyPrice = maxBuy
    updatedOrders = updateOrders market,minBuyAmount,minSaleAmount
    hBuy = updatedOrders[1]
    if (hBuy < maxBuy)
      ourBuyPrice = hBuy + 0.00000001
      orderIDBuy = buy market,buyAmount,ourBuyPrice
    end
    return orderIDBuy, ourBuyPrice
  end


  def totalBtcValue(market, hashPrice)
    #Check initial sell and buy
    hashBal = hashBalance market
    btcBal = btcBalance
    totalValue = btcBal[0] + hashBal[0] * hashPrice
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
    newOrder = @api.trade market, "purchase", amount, price
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
end


module StaticPagesHelper

  require 'open-uri'

  def adding(a=1,b=2)
    c = a + b
  end

  def updateOrdersDatabase

    totalSaleQuantity = 0
    totalSaleAmount = 0
    totalBuyQuantity = 0
    totalBuyAmount = 0
    spread = 0

    Order.delete_all
    api = Hashnest::API.new("oyvind", "KXRQLP4GDEg0UKYGk5hpIafWvgHBreWUn6SzieaD", "8GyWjxTTeIDETiBJvmkCGOTWEWn8Dw9q33uhsEs2")
    @S7orders = api.currency_market_orders "20"
    @S5orders = api.currency_market_orders "19"
    @S4orders = api.currency_market_orders "18"
    @S3orders = api.currency_market_orders "15"

    fillOrders @S7orders, "20"
    fillOrders @S5orders, "19"
    fillOrders @S4orders, "18"
    fillOrders @S3orders, "15"
    
  end

  def fillOrders(orderBook, market)

    @purchase = orderBook["purchase"]
    @sale = orderBook["sale"]

    @purchase.each do |key2| 
      amount = Integer(key2["amount"])
      price = Float(key2["ppc"])
      ordertype = String(key2["category"])
      newOrder = Order.create(price: price, amount: amount, ordertype: ordertype, market: market)
    end
    @sale.each do |key2| 
      amount = Integer(key2["amount"])
      price = Float(key2["ppc"])
      ordertype = String(key2["category"])
      newOrder = Order.create(price: price, amount: amount, ordertype: ordertype, market: market)
     end
  end

  
  def updateDataset
    s7_btc = (Order.where(:ordertype => "purchase").where(:market => "20").maximum(:price) + Order.where(:ordertype => "sale").where(:market => "20").minimum(:price)) / 2.0
    s5_btc = (Order.where(:ordertype => "purchase").where(:market => "19").maximum(:price) + Order.where(:ordertype => "sale").where(:market => "19").minimum(:price)) / 2.0
    s4_btc = (Order.where(:ordertype => "purchase").where(:market => "18").maximum(:price) + Order.where(:ordertype => "sale").where(:market => "18").minimum(:price)) / 2.0
    s3_btc = (Order.where(:ordertype => "purchase").where(:market => "15").maximum(:price) + Order.where(:ordertype => "sale").where(:market => "15").minimum(:price)) / 2.0 
    btc_price = ActiveSupport::JSON.decode(open("https://www.bitstamp.net/api/ticker/").read)["bid"]
    difficulty = ActiveSupport::JSON.decode(open("https://blockexplorer.com/api/status?q=getDifficulty").read)["difficulty"]
    test = Dataset.create(difficulty: difficulty, btc_price: btc_price, s3_btc: s3_btc, s4_btc: s4_btc, s5_btc: s5_btc, s7_btc: s7_btc)
  end



  def saleVolume
    bestPrice = Order.where(:ordertype => "sale").minimum(:price)
    Order.where(:ordertype => "sale").where("price < ?", bestPrice * 1.5).sum("price * amount")
  end

  def buyVolume
    bestPrice = Order.where(:ordertype => "sale").minimum(:price)
    Order.where(:ordertype => "purchase").where("price > ?", bestPrice * 0.5).sum("price * amount")
  end

  def updateDatesDataset
    x = 335
    Dataset.all.each do |item|
      item.created_at = x.days.ago
      item.save
      x = x - 1
    end
  end





end

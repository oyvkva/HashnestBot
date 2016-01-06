class BotController < ApplicationController
    def start
      Pricepoint.create()



      @buttonName = params[:commit]

    if @buttonName == "Run"
      @market = Float(params[:market])
      @hashLeft = Float(params[:hashLeft])
      @btcLeft = Float(params[:btcLeft])
      @tradingPrice = Float(params[:tradingPrice])
      BotWorker.perform_async(@market,@hashLeft,@btcLeft,@tradingPrice)
    else
      puts "Stopped"
    end
  end
end



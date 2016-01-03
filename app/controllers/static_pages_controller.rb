class StaticPagesController < ApplicationController

  require 'roo'

  def home
  end

  def market
  end

  def hashnest_s7
  end
  

  def fetch_excel_data
    ods = Roo::OpenOffice.new("#{Rails.root}/public/testsheet.ods")
    2.upto(356) do |line| 
      difficulty = ods.cell(line,'B')
      btc_price = ods.cell(line,'C')
      s3_btc = ods.cell(line,'D')
      s4_btc = ods.cell(line,'E')
      s5_btc = ods.cell(line,'F')
      s7_btc = ods.cell(line,'G')

      test = Dataset.create(difficulty: difficulty, btc_price: btc_price, s3_btc: s3_btc, s4_btc: s4_btc, s5_btc: s5_btc, s7_btc: s7_btc)
    end
  end

  helper_method :fetch_excel_data
end
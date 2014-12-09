class Split
	def self.spliting
    file = params[:paa]
    image_a = File.open(Rails.root.join('laddu', file), 'r')
    image_b = File.open(Rails.root.join('laddu', 'spleet1.spl'), 'w+')
    image_c = File.open(Rails.root.join('laddu', 'spltee2.spl'), 'w+')
    n=2
      image_a.each_line do |l|
        if n%2==0
          image_b.write(l)    
        else  
           image_c.write(l)
        end
      n=n+1
      end
  image_a.close
  image_b.close
  image_c.close
  redirect_to :controller => "uploads", :action => 'index'
end

end

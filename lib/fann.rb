require 'ruby-fann'
# Example fann program
# Help/docs: http://ruby-fann.rubyforge.org/RubyFann/Standard.html

#train = RubyFann::TrainData.new(:inputs=>[[0.3, 0.4, 0.5], [0.1, 0.2, 0.3]], :desired_outputs=>[[0.7], [0.8]])
#fann = RubyFann::Standard.new(:num_inputs=>3, :hidden_neurons=>[2, 8, 4, 3, 4], :num_outputs=>1)
#fann.train_on_data(train, 1000, 10, 0.1) # 1000 max_epochs, 10 errors between reports and 0.1 desired MSE (mean-squared-error)
#outputs = fann.run([0.3, 0.2, 0.4])   

# (input) feature set: 
#   follower-friend ratio = followers / friends,
#   tweet freq = tweets / time in weeks,
#   favourites freq = favourites / tweets,
#   name pattern (person = 1, thing = 0)
# (output): bot = 0.80, human & bot = 0.55, human = 0.03
train = RubyFann::TrainData.new(:inputs=>[
    [53.9881, 767.9744, 0.0016, 0], # @DiarioTalCual May 2010, 313 weeks
    [17.0278, 3282.7433, 0.0033, 0], # @AmericanAir Mar 2009, 374 weeks 
    [28.6437, 2138.1087, 0.0001, 0],  # @ElUniversal May 2007, 469 weeks
    [22066.2957, 507.2761, 0.0000, 0], # @FoxNews Mar 2007, 478 weeks
    [124.9083, 87.6253, 1.4699, 0], # @NatbyNature Nov 2009, 339 weeks 
    [4.7737, 251.5144, 0.0029, 0], # @psychologicaI May 2012, 208 weeks
    [12189.1683, 5.5796, 0.0959, 0], # @awkwardgoogle Jan 2012, 226 weeks
    [7603.5580, 196.5337, 0.1052, 0], # @verizon Jul 2009, 356 weeks
    [1053.9021, 59.7780, 0.0107, 1], # @carlaangola Sep 2009, 347 weeks
    [19.0594, 67.5533, 0.0014, 1]], # @GirIsWant Aug 2010, 300 weeks
  :desired_outputs=>[
    [0.80], 
    [0.55], 
    [0.80], 
    [0.55],
    [0.03], 
    [0.55], 
    [0.03], 
    [0.80], 
    [0.03], 
    [0.80]])
fann = RubyFann::Standard.new(:num_inputs=>4, :hidden_neurons=>[3, 2], :num_outputs=>1)
#fann = RubyFann::Shortcut.new(:num_inputs=>4, :num_outputs=>1)
fann.train_on_data(train, 1000, 10, 0.1) # 1000 max_epochs, 10 errors between reports and 0.1 desired MSE (mean-squared-error)
outputs = fann.run([40281.8823, 76.4781, 0.0017, 1]) # @ErnestoChavana Oct 2009, 343 weeks, should be 0.03 as this is a human
#outputs = fann.run([12476.2835, 726.4855, 0.0039, 0]) # @PoeticaAcciones Sep 2011, 243 weeks, should be 0.80 as this is a bot
puts outputs 

# save trained data to file and use it later
#train.save('verify.train')
#train = RubyFann::TrainData.new(:filename=>'verify.train')
## Train again with 10000 max_epochs, 20 errors between reports and 0.01 desired MSE (mean-squared-error)
## This will take longer:
#fann.train_on_data(train, 10000, 20, 0.01) 

# save trained network to file and use it later
#fann.save('foo.net')
#saved_nn = RubyFann::Standard.new(:filename=>"foo.net")
#saved_nn.run([0.3, 0.2, 0.4])


require 'ruby-fann'

train = RubyFann::TrainData.new(:inputs=>[[0.3, 0.4, 0.5], [0.1, 0.2, 0.3]], :desired_outputs=>[[0.7], [0.8]])
fann = RubyFann::Standard.new(:num_inputs=>3, :hidden_neurons=>[2, 8, 4, 3, 4], :num_outputs=>1)
fann.train_on_data(train, 1000, 10, 0.1) # 1000 max_epochs, 10 errors between reports and 0.1 desired MSE (mean-squared-error)
outputs = fann.run([0.3, 0.2, 0.4])   

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


require 'kmeans-clusterer'
# Example kmeans program

# (input) feature set: 
#   follower-friend ratio = followers / friends,
#   tweet freq = tweets / time in weeks,
#   favourites freq = favourites / tweets,
#   name pattern (person = 1, thing = 0)
data = [[53.9881, 767.9744, 0.0016, 0], # bot, @DiarioTalCual May 2010, 313 weeks
        [17.0278, 3282.7433, 0.0033, 0], # human & bot, @AmericanAir Mar 2009, 374 weeks
        [28.6437, 2138.1087, 0.0001, 0], # bot, @ElUniversal May 2007, 469 weeks
        [22066.2957, 507.2761, 0.0000, 0], # human & bot, @FoxNews Mar 2007, 478 weeks
        [124.9083, 87.6253, 1.4699, 0], # human, @NatbyNature Nov 2009, 339 weeks
        [4.7737, 251.5144, 0.0029, 0], # human & bot, @psychologicaI May 2012, 208 weeks
        [12189.1683, 5.5796, 0.0959, 0], # human, @awkwardgoogle Jan 2012, 226 weeks
        [7603.5580, 196.5337, 0.1052, 0], # bot, @verizon Jul 2009, 356 weeks
        [1053.9021, 59.7780, 0.0107, 1], # human, @carlaangola Sep 2009, 347 weeks
        [19.0594, 67.5533, 0.0014, 1]] # bot, @GirIsWant Aug 2010, 300 weeks

labels = ['@DiarioTalCual',
          '@AmericanAir',
          '@ElUniversal',
          '@FoxNews',
          '@NatbyNature',
          '@psychologicaI',
          '@awkwardgoogle',
          '@verizon',
          '@carlaangola', 
          '@GirIsWant']

k = 6 # find k clusters in data

kmeans = KMeansClusterer.run k, data, labels: labels, runs: 5
#kmeans = KMeansClusterer.run k, data, labels: labels, runs: 5, init: random, scale_data: false, float_precision: double, max_iter: 300
#kmeans = KMeansClusterer.run k, data, labels: labels, runs: 5, init: kmpp, scale_data: false, float_precision: double, max_iter: 300

kmeans.clusters.each do |cluster|
  puts  cluster.id.to_s + '. ' + 
        cluster.points.map(&:label).join(", ") + "\t" +
        cluster.centroid.to_s
end

# Use existing clusters for prediction with new data:
predicted = kmeans.predict [[12476.2835, 726.4855, 0.0039, 0]] # bot, @PoeticaAcciones Sep 2011, 243 weeks
puts "\nClosest cluster to @PoeticaAcciones: #{predicted[0]}"

# Clustering quality score. Value between -1.0..1.0 (1.0 is best)
puts "\nSilhouette score: #{kmeans.silhouette.round(2)}"


require 'kmeans-clusterer'
# Example kmeans program

data = [[40.71,-74.01],[34.05,-118.24],[39.29,-76.61],
        [45.52,-122.68],[38.9,-77.04],[36.11,-115.17]]

labels = ['New York', 'Los Angeles', 'Baltimore', 
          'Portland', 'Washington DC', 'Las Vegas']

k = 2 # find 2 clusters in data

kmeans = KMeansClusterer.run k, data, labels: labels, runs: 5

kmeans.clusters.each do |cluster|
  puts  cluster.id.to_s + '. ' + 
        cluster.points.map(&:label).join(", ") + "\t" +
        cluster.centroid.to_s
end

# Use existing clusters for prediction with new data:
predicted = kmeans.predict [[41.85,-87.65]] # Chicago
puts "\nClosest cluster to Chicago: #{predicted[0]}"

# Clustering quality score. Value between -1.0..1.0 (1.0 is best)
puts "\nSilhouette score: #{kmeans.silhouette.round(2)}"


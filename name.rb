require "json"

class Name

	def name; return "name" end

	def run param = nil

		names = JSON.load( File.new("Apps/name/names.json",'r') )
		
		puts sample(10, names).flatten.select.each_with_index { |_, i| i.even? }
		content = stats(10000, 20, names)

		# content = sample(10, names)
		
		write_to_file("Apps/name/", "names_stats.json", content)

		return "Done!"

	end

	def sample quantity, data
		
		# shuffle the indexes for a uniform distribution
		names = data.shuffle
		stored_values = []

		# iterate over the indexes
		names.each do |element|
			# end the loop if you have all the values you need
			if (stored_values.count >= quantity)
				# puts "valuescount = #{stored_values.size}"
				break
			end

			# generate a new score value
			score = rand(0..10)

			# get the current element
			get = element
			
			# check if it's a hash
			if get.is_a?(Hash)
				# skip if the group's score is less than the score_check value
				next unless get["score"] >= score

				# shuffle the group
				group = get["data"].shuffle

				# check how likely the group is to repeat (max score of 10)
				chance_score = get["chance"]
				
				# set the current chance threshold at 1 so that the first element is guaranteed to come up
				chance_threshold = 0
				
				# iterate on the group
				group.each do |group_element|
					break if (stored_values.count >= quantity)
					break if chance_threshold > chance_score && score > group_element.last
					
					# all the checks have passed. store the value
					store_value(stored_values, group_element)

					# reset score and chance thresholds
					score = rand(0..10)
					chance_threshold = rand(0..10)
				end
			else
				# skip if the element's score is less than the score_check value
				next unless get.last >= score
				store_value(stored_values, get)
			end
		end

		return stored_values

	end

	def store_value array, value

		unless value == nil 
			array.push(value)
		else
			puts("nil value!")
		end

	end

	def stats loops, sample_size, data
		
		record = {}
		loops.times do
			this_sample = sample(sample_size, data)
			this_sample.each do |i|
				if record.include?(i.first)
					record[i.first] += 1
				else
					record[i.first] = 1
				end
			end
		end

		total = 0
		record.each do |key,value|
			total += value
		end
		# puts(total)

		return record.sort_by{|value,qty|qty}.reverse.to_h
	end


	def write_to_file path, file_name, data
		File.open("#{path}/#{file_name}", "w") do |file|
			file.write(JSON.pretty_generate(data))    
		end
	end

end
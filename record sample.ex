# Datset

%KNN.Helper.KeelDataset {
	attributes: [%KNN.Helper.KeelAttribute{
		data: { :range,
			{
				4.3,
				7.9
			}
		},
		inner_data_type: :number,
		name: "SepalLength"
	}, %KNN.Helper.KeelAttribute{
		data: { :range,
			{
				2.0,
				4.4
			}
		},
		inner_data_type: :number,
		name: "SepalWidth"
	}, %KNN.Helper.KeelAttribute{
		data: { :range,
			{
				1.0,
				6.9
			}
		},
		inner_data_type: :number,
		name: "PetalLength"
	}, %KNN.Helper.KeelAttribute{
		data: { :range,
			{
				0.1,
				2.5
			}
		},
		inner_data_type: :number,
		name: "PetalWidth"
	}, %KNN.Helper.KeelAttribute{
		data: { :set,
			["Iris-setosa", "Iris-versicolor", "Iris-virginica"]
		},
		inner_data_type: nil,
		name: "Class"
	}],
	input_attributes: ["SepalLength", "SepalWidth", "PetalLength", "PetalWidth"],
	output_attributes: ["Class"],
	relation: "iris",
	valid: true
}

# Record
%{
	"Class" => "Iris-virginica",
	"PetalLength" => 4.8,
	"PetalWidth" => 1.8,
	"SepalLength" => 6.2,
	"SepalWidth" => 2.8
}
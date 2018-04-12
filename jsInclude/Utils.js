function valiDate(dateField) {
    var dateRegex = /^([01]?[0-9])([\/\-])([0-3]?[0-9])\2(20)?(\d\d)$/;
    var dateString = dateField.value;
    var returnDate = "";
    
    if (dateString != "") {
        // Check if string is a date
        if (dateString.match(dateRegex)) {
            var dateMatch = dateRegex.exec(dateString);
            if (dateMatch[1]<13 && dateMatch[3]<32) {
                returnDate = dateMatch[1] + "/" + dateMatch[3] + "/20" + dateMatch[5];
            }
        }

		//Fill out the date field with the formatted date (this will be an empty string if the date was invalid)
        dateField.value = returnDate;
        if (returnDate == "") {
            // Timeout is necessary in FF because it fires the onblur event before on focus if focus is executed directly
            setTimeout(function(){dateField.focus();}, 10); 
        }
    }
}

function calculateLinearRegression(values_xy) {
	var sum_x = 0;
	var sum_y = 0;
	var sum_xy = 0;
	var sum_xx = 0;
	var count = 0;
	var x = 0;
	var y = 0;
	var values_length = values_xy.length;

	if (values_length === 0) {
		return [ [] ];
	}

	// Calculate the sum for each of the parts necessary.
	for (var v = 0; v < values_length; v++) {
		x = values_xy[v][0];
		y = values_xy[v][1];
		sum_x += x;
		sum_y += y;
		sum_xx += x*x;
		sum_xy += x*y;
		count++;
	}

	// y = x * m + b
	var m = (count*sum_xy - sum_x*sum_y) / (count*sum_xx - sum_x*sum_x);
	var b = (sum_y/count) - (m*sum_x)/count;

	// Create result line
	var result_values_xy = [];

	for (var v = 0; v < values_length; v++) {
		x = values_xy[v][0];
		y = x * m + b;
		result_values_xy.push([x, y]);
	}
	return result_values_xy;
}

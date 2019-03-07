// Designs.js

function client_log(caller, msg) {
  console.log(caller + ": " + msg);
}

function makePost(row, col, color) {
	var url = "http://localhost:80/";
	
	var params = "row=" + row + "&col=" + col + "&color=" + color;
	var xhr = new XMLHttpRequest();
	xhr.open("POST",url,true);
	
	xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

	xhr.send(params);
}

// It's worth noting that the grid parsing and generation function
// share the pattern of handling the grid as an Array of rows.
// Therefore indexing will be inverted.
//     Array[y-cor][x-cor]
function makeGrid(height, width, cell_values){
    console.log(cell_values);
    $("tr").remove();
    for (var i = 0; i < height; i++) {
        $("#pixelCanvas").append("<tr id=row" + i + "></tr>");
        for (var y = 0; y < width; y++) {
            $("#row" + i).append("<td id=col"+y+"></td>");
	    $("#row" + i + " #col" + y).css("background-color", cell_values[i][y]);
	}
    }

    $("#pixelCanvas").on("click", "td", function() {
        $(this).css("background-color", $("#colorPicker").val());
	//makePost(15,1,$("#colorPicker").val());
	makePost(15,1,"#000000");
	//client_log("help",$("#colorPicker").val());


    });
}

// TODO: This should either not be hardcoded or be more configurable.
hostname = "http://localhost:80/";
//hostname = "http://34.73.178.251/";
// TODO: move these somewhere more logical.
GET_GRID_ENDPOINT = "canvas";
// Global state: object nature makes it pass-by-ref.
state = {
  grid: [],
};

// Makes an http request to retrieve grid and parses data into a client
// structure, which is returned.
function get_grid(handler) {
  client_log("GET_GRID", "requesting updated grid...");
  $.get(hostname+GET_GRID_ENDPOINT, {}, function (resp) {
    // Map csv string into 2d numeric array.
    // TODO: double-check this filter for correctness
    client_log(resp);
    state.grid = resp.split("\n").filter(function(v) { return v; })
		                 .map(function(line) {
                                   return line.split(",")
					      .map(function(s) {
					        return s.substring(1, s.length-1);
					      })
					      .filter(function (v) { return v; });
                                  });
    makeGrid(state.grid.length, state.grid[0].length, state.grid);
  });
}

function update_grid() {
  get_grid();
}

//makeGrid(40,40);
// This code is implicitly an onload(), as the script doesn't load
// until one of the body elements does.
makePost(19,19,"#000000");
this.grid = update_grid();

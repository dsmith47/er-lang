// Designs.js

function client_log(caller, msg) {
  console.log(caller + ": " + msg);
}

// It's worth noting that the grid parsing and generation function
// share the pattern of handling the grid as an Array of rows.
// Therefore indexing will be inverted.
//     Array[y-cor][x-cor]
function makeGrid(height, width, cell_values){
    $("tr").remove();
    for (var i = 0; i < height; i++) {
        $("#pixelCanvas").append("<tr id=row" + i + "></tr>");
        for (var y = 0; y < width; y++) {
            $("#row" + i).append("<td id=col"+y+"></td>");
	    $("#row" + i + " #col" + y).attr("style","background-color", cell_values[i][y])
        }
    }

    /*"td").click(function cellColor() {
        color = $("#colorPicker").val();
        if ($(this).attr("style")) {
            $(this).removeAttr("style")
        } else {
            $(this).attr("style", "background-color: " + color);
        }
    });*/
    $("#pixelCanvas").on("click", "td", function() {

        $(this).css("background-color", $("#colorPicker").val());

    });
}

// TODO: This should either not be hardcoded or be more configurable.
hostname = "http://localhost:8081/";
// TODO: move these somewhere more logical.
GET_GRID_ENDPOINT = "";
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
    // TODO: double-check this filter for correctness.
    state.grid = resp.split("\n").filter(function(v) { return v; })
		                 .map(function(line) {
                                   return line.split(",").filter(function(v) {return v.length})
                                                         .map(parseInt)
					                 .map(function (v) {if (v) {return v;} else {return 0;}});
					                 
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
this.grid = update_grid();

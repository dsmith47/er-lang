// Designs.js

function makeGrid(height, width){
    $("tr").remove();
    for (var i = 1; i <= height; i++) {
        $("#pixelCanvas").append("<tr id=row" + i + "></tr>");
        for (var y = 1; y <= width; y++) {
            $("#row" + i).append("<td></td>");
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

makeGrid(40,40);

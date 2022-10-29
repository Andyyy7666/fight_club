$(function() {
    window.addEventListener("message", function(event) {
        const item = event.data;
        if (item.type == "barStatus") {
            if (item.display) {
                $(".bar").fadeIn();
                $(".barLevel").css("width", "100%");
            } else {
                $(".bar").fadeOut();
            };
        };

        if (item.type == "barLevel") {
            $(".barLevel").css("width", item.level + "%");
        };
    });
});
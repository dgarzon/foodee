jQuery ->
	$(".close").on("click", () ->
		$("#search-input").geocomplete
		    # types: ["formatted_address"]
		    locality: "NYC"
	)
  
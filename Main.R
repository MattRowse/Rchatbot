library(plumber)
# run the plumber api to get responses
rapi <- plumber::plumb("rest_controller.R")  # Where 'api.R' is the location of the code file shown above 
rapi$run(port=8000, host = "0.0.0.0")


ImagesGrabber::Application.routes.draw do

  root to: "img_grab#index"
  post "grabber", to: "img_grab#grabber",  as: "grabber"
  get  "booties", to: "img_grab#booties",  as: "booties"
  get  "show_booty", to: "img_grab#show_booty", as: "show"

end

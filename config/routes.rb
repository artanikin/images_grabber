ImagesGrabber::Application.routes.draw do

  root to: "img_grab#index"
  post "grabber", to: "img_grab#grabber",  as: "grabber"
  get  "bootys",  to: "img_grab#bootys",   as: "bootys"
  get  "show_booty/:dir", to: "img_grab#show_booty", as: "show"

end

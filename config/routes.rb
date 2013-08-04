ImagesGrabber::Application.routes.draw do

  root to: "img_grab#index"
  get "img_grab/grabber", as: "grabber"

end

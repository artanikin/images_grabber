ImagesGrabber::Application.routes.draw do

  root to: "img_grab#index"
  post "img_grab/grabber", as: "grabber"

end

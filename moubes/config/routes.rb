Rails.application.routes.draw do
  get 'main/home'
  root 'main#home'
  get 'main/userpage' => 'main#userpage'
  get 'main/allusers' => 'main#allusers'
  get 'main/refresh' => 'main#refresh'
	get 'main/download_csv' => 'main#download_csv'
end

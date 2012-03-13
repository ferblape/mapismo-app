require 'acceptance/acceptance_helper'

feature 'Maps' do

  scenario %q{
    A new user connects to CartoDB
    And is redirected to new map action
  } do
    mock_cartodb_oauth(uid: 1)
    
    user = mock()
    user.stubs(:username).returns('blat')
    user.stubs(:maps).returns([])
    user.stubs(:id).returns(1)
    User.stubs(:find).with(1).returns(user)
    
    visit "/"
    
    click "Login using CartoDB"
    
    page.should have_content("Hi blat!")
    page.should have_content("Create a new map")
    
    fill_in "name", with: "15M in Madrid"
    fill_in "keywords", with: "15m, madrid"
    check "flickr"
    check "instagram"
    fill_in "location", with: "Madrid"
    fill_in "radius", with: "1500"
    fill_in "latitude", with: 40.416691
    fill_in "longitude", with: -3.700345
    fill_in "start date", with: "2011-05-15+00:00:00"
    fill_in "end date", with: "2011-05-15+23:59:59"
    
    map = mock()
    map.stubs(:id).returns(1)
    map.stubs(:save).returns(true)
    map.stubs(:name).returns("15M in Madrid")
    Map.stubs(:new).returns(map)
    Map.stubs(:find).returns(map)
    
    click "save this map"
    
    page.should have_content("Your map has been created successfully")
    page.should have_content("15M in Madrid")
  end
  
  scenario %q{
    An existing user with maps connects to CartoDB
    And is redirected to his list of maps
  } do
    mock_cartodb_oauth(uid: 1)
    
    map = mock()
    map.stubs(:id).returns(1)
    map.stubs(:name).returns("15M in Madrid")
    
    user = mock()
    user.stubs(:username).returns('blat')
    user.stubs(:maps).returns([map])
    user.stubs(:id).returns(1)
    User.stubs(:find).with(1).returns(user)
    
    visit "/"
    
    click "Login using CartoDB"
    
    page.should have_content("Hi blat!")
    page.should have_content("Your maps")
    page.should have_content("15M in Madrid")
  end

end

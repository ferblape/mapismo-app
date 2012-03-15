require 'acceptance/acceptance_helper'

feature 'Maps' do

  scenario %q{
    A new user connects to CartoDB
    And is redirected to new map action
  } do
    mock_cartodb_oauth(uid: 1, username: 'blat')
    
    user = mock()
    user.stubs(:username).returns('blat')
    user.stubs(:maps).returns([])
    user.stubs(:data_table_id).returns(3)
    user.stubs(:id).returns(1)
    User.stubs(:find).returns(user)
    
    visit "/"
    
    click "Login using CartoDB"
    
    page.should have_content("Creating a map with")
    page.find("#top_bar").all("a").first.click
    uncheck "Flickr"
    page.find("ul#keywords_list").find("a.delete").click
    
    map = mock()
    map.stubs(:id).returns(1)
    map.stubs(:save).returns(true)
    map.stubs(:name).returns("Instagram photos about 15m in Madrid on Mar 14th - Mar 15th")
    Map.stubs(:new).returns(map)
    Map.stubs(:find).returns(map)
    
    click "Save map"
    
    page.should have_content("This is a map with Instagram photos about 15m in Madrid on Mar 14th - Mar 15th")
  end
  
  pending %q{
    An existing user with maps connects to CartoDB
    And is redirected to his list of maps
  } do
    mock_cartodb_oauth(uid: 1, username: 'blat')
    
    map = mock()
    map.stubs(:id).returns(1)
    map.stubs(:name).returns("15M in Madrid")
    Map.stubs(:find).returns(map)
    
    user = mock()
    user.stubs(:username).returns('blat')
    user.stubs(:id).returns(1)
    User.stubs(:find).with(1).returns(user)
    
    User.any_instance.stubs(:maps).returns([map])
    
    visit "/"
    
    click "Login using CartoDB"
    
    page.should have_content("Hi blat!")
    page.should have_content("Your maps")
    page.should have_content("15M in Madrid")
    click "15M in Madrid"
    
    page.should have_css("h2", text: "15M in Madrid")
  end

end

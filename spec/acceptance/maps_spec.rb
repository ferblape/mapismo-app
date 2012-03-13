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

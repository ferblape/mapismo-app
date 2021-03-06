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
    check "instagram"
    page.find("ul#keywords_list").find("a.delete").click

    map = mock()
    map.stubs(:id).returns(1)
    map.stubs(:save).returns(true)
    map.stubs(:name).returns("Flickr and Instagram photos about fallas in Valencia on Mar 1st - Mar 19th 2012")
    Map.stubs(:new).returns(map)
    Map.stubs(:find).returns(map)

    click "Go"

    page.should have_content("Fetching results...")
  end

  scenario %q{
    An existing user with maps connects to CartoDB
    And is redirected to his list of maps
  } do
    mock_cartodb_oauth(uid: 1, username: 'blat')

    map = mock()
    map.stubs(:id).returns(1)
    map.stubs(:name).returns("Flickr photos about 15M in Madrid")
    map.stubs(:lat).returns(1.3)
    map.stubs(:lon).returns(-0.5)
    Map.stubs(:find).returns(map)

    user = mock()
    user.stubs(:username).returns('blat')
    user.stubs(:data_table_id).returns(3)
    user.stubs(:id).returns(1)
    User.stubs(:find).returns(user)

    User.any_instance.stubs(:maps).returns([map])

    visit "/"

    click "Login using CartoDB"

    page.should have_content("Your maps")
    page.should have_content("15M in Madrid")
    click "15M in Madrid"

    page.should have_css("h1", text: "This is a map with Flickr photos about 15M in Madrid")
  end

end

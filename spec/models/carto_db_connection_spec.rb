# coding: UTF-8

require 'spec_helper'

describe "MapismoApp::CartoDBConnection" do
  let(:connection){ mock() }
  
  it "should require a connection when initialized" do
    lambda {
      MapismoApp::CartoDBConnection.new(nil)
    }.should raise_error("Connection is required")
    
    c = MapismoApp::CartoDBConnection.new(connection)
    c.should_not be_nil
  end
  
  context "valid connection" do
    subject do
      MapismoApp::CartoDBConnection.new(mock())
    end
    
    describe "#table_exists?" do
      it "should return true when the table exists in CartoDB" do
        connection.stubs(:response).returns(mocked_response(200))
        subject.stubs(:connection).returns(connection)
        
        subject.expects(:run_query).returns(true)
        
        subject.table_exists?("table1").should be_true
      end

      it "should return false when the table does not exist in CartoDB" do
        response = mocked_response(404)
        connection.stubs(:response).returns(response)
        subject.stubs(:connection).returns(connection)
        
        subject.expects(:run_query).returns(true)
        
        subject.table_exists?("table1").should be_false
      end
    end
    
    describe "#create_table" do
      it "should return true when the table has been created" do
        connection.stubs(:response).returns(mocked_response(200))
        connection.expects(:post).with("/api/v1/tables", {name: "new_table_name", schema: "f1 varchar, f2 integer"})
        subject.stubs(:connection).returns(connection)
        
        subject.create_table("new_table_name", "f1 varchar, f2 integer").should be_true
      end
      
      it "should return false when the table could not be created" do
        response = mocked_response("400")
        connection.stubs(:response).returns(response)
        connection.expects(:post).with("/api/v1/tables", {name: "new_table_name", schema: "f1 varchar, f2 integer"})
        subject.stubs(:connection).returns(connection)
        
        subject.create_table("new_table_name", "f1 varchar, f2 integer").should == response
      end
    end
    
    describe "#reset_table" do
      it "should run a DELETE query" do
        subject.expects(:run_query).with("DELETE FROM new_table_name")
        subject.reset_table("new_table_name")
      end
    end
    
    describe "#find_row" do
      it "should return an existing row in case that exists" do
        json = {
          total_rows: 1,
          rows: [
            {id: 1, name: 'wadus'}
          ]
        }
        response = mock()
        response.stubs(:code).returns("200")
        response.stubs(:body).returns(json.to_json)
        
        connection.stubs(:response).returns(response)
        subject.stubs(:connection).returns(connection)
        
        subject.expects(:run_query).with("SELECT * FROM table_name WHERE 1=1 LIMIT 1")
        subject.find_row("table_name", "1=1").should == json[:rows][0].stringify_keys
      end
      
      it "should return nil if the row does not exist" do
        json = {
          total_rows: 0,
          rows: []
        }
        response = mock()
        response.stubs(:code).returns("200")
        response.stubs(:body).returns(json.to_json)
        
        connection.stubs(:response).returns(response)
        subject.stubs(:connection).returns(connection)
        
        
        subject.expects(:run_query).with("SELECT * FROM table_name WHERE 1=1 LIMIT 1")
        subject.find_row("table_name", "1=1").should be_nil
      end
      
      it "should return nil if the table does not exist" do
        connection.stubs(:response).returns(mocked_response(404))
        subject.stubs(:connection).returns(connection)
        
        
        subject.expects(:run_query).with("SELECT * FROM table_name WHERE 1=1 LIMIT 1")
        subject.find_row("table_name", "1=1").should be_nil
      end
    end

    describe "#insert_row" do
      let(:attributes){ {a: '1', b: '2'} }
      it "should insert data into a new row and return true if success" do
        connection.stubs(:response).returns(mocked_response(200))
        subject.stubs(:connection).returns(connection)
        
        subject.expects(:run_query).with("INSERT INTO table1 (a,b) VALUES ('1','2')", :post)
        subject.insert_row("table1", attributes).should be_true
      end
      
      it "should return the error if failure" do
        response = mocked_response(400)
        connection.stubs(:response).returns(response)
        subject.stubs(:connection).returns(connection)
        
        subject.expects(:run_query).with("INSERT INTO table1 (a,b) VALUES ('1','2')", :post)
        subject.insert_row("table1", attributes).should == response
      end
    end
    
    context "private method" do
      describe "#run_query" do
        it "should call API endpoint with the given query" do
          query = "SELECT * FROM wadus"
          request = Mapismo.cartodb_api_endpoint + "?q=" + CGI.escape(query)
        
          connection.expects(:post).with(request).once.returns(true)
          connection.stubs(:response).returns(mocked_response(200))

          subject.stubs(:connection).returns(connection)
        
          subject.send(:run_query, query, :post)
        end
      end
      
      describe "#convert_to_insert_query" do
        it "should convert a name and a hash of attributes into a valid insert query" do
          attributes = {a: '1', b: '2'}
          subject.send(:convert_to_insert_query,'table_1', attributes).should == "INSERT INTO table_1 (a,b) VALUES ('1','2')"
        end
      end
    end
  end
end
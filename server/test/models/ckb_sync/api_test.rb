require "test_helper"

module CkbSync
  class ApiTest < ActiveSupport::TestCase
    test "should contain related methods" do
      contained_method_names = CkbSync::Api::METHOD_NAMES
      sdk_api_names = CKB::API.instance_methods(false)

      assert_equal sdk_api_names.map(&:to_s).sort, contained_method_names.sort
    end

    test "should reassign api when current connected ckb node is down" do
      VCR.use_cassette("blocks/10", record: :new_episodes) do
        fake_node_block = '{
        "transactions":[
          {"deps":[],"hash":"0xc30257c81dde7766fc98882ff1e9f8e95abbe79345982e12c6a849de90cbbad5","inputs":[{"args":["0x0700000000000000"],"previous_output":{"tx_hash":"0x18bd084635d5a1190e6a17b49ae641a08f0805f7c9c7ea68cd325a2e19d9bdea","index":0},"since":"0"}],"outputs":[{"capacity":"50000","data":"0x","lock":{"args":["0x18bd084635d5a1190e6a17b49ae641a08f0805f7c9c7ea68cd325a2e19d9bdea"],"code_hash":"0x8bddddc3ae2e09c13106634d012525aa32fc47736456dba11514d352845e561d"},"type":null}],"version":0,"witnesses":[]}
        ],
        "header":{"difficulty":"0x1000","hash":"0x267959408f66f8afd3723e0826a39a884b845c84fdc2ebbf519cb1e22ab07ec6","number":"7","parent_hash":"0x1d14ede560b0da3272894c5a770cc9bfe69369231addb49d7385c101ef2851da","seal":{"nonce":"10247006937625797729","proof":"0xab0b0000d11c00001d320000da3d0000fe3f0000094b00007f580000186200004463000035650000526b0000c9790000"},"timestamp":"1555604459380","transactions_root":"0xc30257c81dde7766fc98882ff1e9f8e95abbe79345982e12c6a849de90cbbad5","proposals_root":"0x0000000000000000000000000000000000000000000000000000000000000000","uncles_count":2,"uncles_hash":"0x7683fa1e36cec641dc5f1c28368c46edc2ddbfd2a2b2e4c93dc461a28f2ae124","version":0,"witnesses_root":"0x0000000000000000000000000000000000000000000000000000000000000000"},"proposals":[],"uncles":[{"header":{"difficulty":"0x1000","hash":"0x377839c54f0a0c40b6638ac2447ba3094e48aec4366535ab40e0d95a7b68338d","number":"2","parent_hash":"0x136996eaeede9482bf47b9bce9f992c50d85bd94402a5078ea3206a90bf62e86","seal":{"nonce":"5202350849395149656","proof":"0x9d1c00006f250000d82c0000c2300000a2430000194e0000cf5a000048670000236c0000ef720000c87a0000e37f0000"},"timestamp":"1555604163266","transactions_root":"0x9defbef60635e92d77ec14a393e0e9701f87b02190bf3bbb37be760946ac4f73","proposals_root":"0x0000000000000000000000000000000000000000000000000000000000000000","uncles_count":0,"uncles_hash":"0x0000000000000000000000000000000000000000000000000000000000000000","version":0,"witnesses_root":"0x0000000000000000000000000000000000000000000000000000000000000000"},"proposals":[]},{"header":{"difficulty":"0x1000","hash":"0x6af4cb1d4b2f8d6b05be9a6d713203ae9f3191b2cab805fe1ebeec12448e737a","number":"1","parent_hash":"0x298f349c8cdfadf46e8008e72afe6da78b1ea1b7d86470ea71bb0e404c5c9d7f","seal":{"nonce":"7551133712902986728","proof":"0x81070000841f0000f7210000a022000037230000d22f00003c4900003c5300000d5a00000d640000c46d00004f7c0000"},"timestamp":"1555604128584","transactions_root":"0xbd9ed8dec5288bdeb2ebbcc4c118a8adb6baab07a44ea79843255ccda6c57915","proposals_root":"0x0000000000000000000000000000000000000000000000000000000000000000","uncles_count":0,"uncles_hash":"0x0000000000000000000000000000000000000000000000000000000000000000","version":0,"witnesses_root":"0x0000000000000000000000000000000000000000000000000000000000000000"},"proposals":[]}]
        }'
        genesis_block = JSON.parse(fake_node_block, symbolize_names: true)
        CKB::API.any_instance.stubs(:genesis_block).returns(genesis_block)
        CKB::API.expects(:new).raises(JSON::ParserError).twice
        Settings.stubs(:hosts).returns(["http://11.111.111.111:1111"])
        ENV["CKB_NODE_URL"] = "http://11.111.111.111:1112/"
        assert_raise JSON::ParserError do
          Class.new(CkbSync::Api).instance
        end
      end
    end

    test "should reassign api when call rpc the ckb node is down" do
      VCR.use_cassette("genesis_block") do
        VCR.use_cassette("blocks/10", record: :new_episodes) do
          ENV["CKB_NODE_URL"] = "http://11.111.111.111:1111/"
          fake_node_block = '{
          "transactions":[
            {"deps":[],"hash":"0xc30257c81dde7766fc98882ff1e9f8e95abbe79345982e12c6a849de90cbbad5","inputs":[{"args":["0x0700000000000000"],"previous_output":{"tx_hash":"0x18bd084635d5a1190e6a17b49ae641a08f0805f7c9c7ea68cd325a2e19d9bdea","index":0},"since":"0"}],"outputs":[{"capacity":"50000","data":"0x","lock":{"args":["0x18bd084635d5a1190e6a17b49ae641a08f0805f7c9c7ea68cd325a2e19d9bdea"],"code_hash":"0x8bddddc3ae2e09c13106634d012525aa32fc47736456dba11514d352845e561d"},"type":null}],"version":0,"witnesses":[]}
          ],
          "header":{"difficulty":"0x1000","hash":"0x267959408f66f8afd3723e0826a39a884b845c84fdc2ebbf519cb1e22ab07ec6","number":"7","parent_hash":"0x1d14ede560b0da3272894c5a770cc9bfe69369231addb49d7385c101ef2851da","seal":{"nonce":"10247006937625797729","proof":"0xab0b0000d11c00001d320000da3d0000fe3f0000094b00007f580000186200004463000035650000526b0000c9790000"},"timestamp":"1555604459380","transactions_root":"0xc30257c81dde7766fc98882ff1e9f8e95abbe79345982e12c6a849de90cbbad5","proposals_root":"0x0000000000000000000000000000000000000000000000000000000000000000","uncles_count":2,"uncles_hash":"0x7683fa1e36cec641dc5f1c28368c46edc2ddbfd2a2b2e4c93dc461a28f2ae124","version":0,"witnesses_root":"0x0000000000000000000000000000000000000000000000000000000000000000"},"proposals":[],"uncles":[{"header":{"difficulty":"0x1000","hash":"0x377839c54f0a0c40b6638ac2447ba3094e48aec4366535ab40e0d95a7b68338d","number":"2","parent_hash":"0x136996eaeede9482bf47b9bce9f992c50d85bd94402a5078ea3206a90bf62e86","seal":{"nonce":"5202350849395149656","proof":"0x9d1c00006f250000d82c0000c2300000a2430000194e0000cf5a000048670000236c0000ef720000c87a0000e37f0000"},"timestamp":"1555604163266","transactions_root":"0x9defbef60635e92d77ec14a393e0e9701f87b02190bf3bbb37be760946ac4f73","proposals_root":"0x0000000000000000000000000000000000000000000000000000000000000000","uncles_count":0,"uncles_hash":"0x0000000000000000000000000000000000000000000000000000000000000000","version":0,"witnesses_root":"0x0000000000000000000000000000000000000000000000000000000000000000"},"proposals":[]},{"header":{"difficulty":"0x1000","hash":"0x6af4cb1d4b2f8d6b05be9a6d713203ae9f3191b2cab805fe1ebeec12448e737a","number":"1","parent_hash":"0x298f349c8cdfadf46e8008e72afe6da78b1ea1b7d86470ea71bb0e404c5c9d7f","seal":{"nonce":"7551133712902986728","proof":"0x81070000841f0000f7210000a022000037230000d22f00003c4900003c5300000d5a00000d640000c46d00004f7c0000"},"timestamp":"1555604128584","transactions_root":"0xbd9ed8dec5288bdeb2ebbcc4c118a8adb6baab07a44ea79843255ccda6c57915","proposals_root":"0x0000000000000000000000000000000000000000000000000000000000000000","uncles_count":0,"uncles_hash":"0x0000000000000000000000000000000000000000000000000000000000000000","version":0,"witnesses_root":"0x0000000000000000000000000000000000000000000000000000000000000000"},"proposals":[]}]
          }'
          genesis_block = JSON.parse(fake_node_block, symbolize_names: true)
          CKB::API.any_instance.stubs(:genesis_block).returns(genesis_block)
          CKB::API.any_instance.expects(:send).raises(JSON::ParserError).twice
          assert_raise JSON::ParserError do
            Class.new(CkbSync::Api).instance.get_tip_block_number
          end
        end
      end
    end
  end
end

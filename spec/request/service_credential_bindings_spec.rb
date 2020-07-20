require 'spec_helper'
require 'request_spec_shared_examples'

RSpec.describe 'v3 service credential bindings' do
  let(:user) { VCAP::CloudController::User.make }
  let(:org) { VCAP::CloudController::Organization.make }
  let(:space) { VCAP::CloudController::Space.make(organization: org) }
  let(:other_space) { VCAP::CloudController::Space.make }

  describe 'GET /v3/service_credential_bindings/:key_guid' do
    context 'key exists' do
      let(:key) { VCAP::CloudController::ServiceKey.make(service_instance: instance) }
      let(:instance) { VCAP::CloudController::ManagedServiceInstance.make(space: space) }
      let(:api_call) { ->(user_headers) { get "/v3/service_credential_bindings/#{key.guid}", nil, user_headers } }

      context 'global roles' do
        let(:expected_codes_and_responses) do
          Hash.new({ code: 200, response_object: { guid: key.guid } })
        end

        it_behaves_like 'permissions for single object endpoint', GLOBAL_SCOPES
      end

      context 'local roles' do
        context 'user is in the original space of the service instance' do
          let(:expected_codes_and_responses) do
            Hash.new({ code: 200, response_object: { guid: key.guid } }).tap do |h|
              h['org_auditor'] = { code: 404 }
              h['org_billing_manager'] = { code: 404 }
              h['no_role'] = { code: 404 }
            end
          end

          it_behaves_like 'permissions for single object endpoint', LOCAL_ROLES
        end

        context 'user is in a space that the service instance is shared to' do
          let(:instance) { VCAP::CloudController::ManagedServiceInstance.make(space: other_space) }

          before do
            instance.add_shared_space(space)
          end

          let(:api_call) { ->(user_headers) { get "/v3/service_credential_bindings/#{key.guid}", nil, user_headers } }

          let(:expected_codes_and_responses) do
            Hash.new(code: 404)
          end

          it_behaves_like 'permissions for single object endpoint', LOCAL_ROLES
        end
      end
    end

    context 'no such binding exists' do
      let(:api_call) { ->(user_headers) { get '/v3/service_credential_bindings/no-binding', nil, user_headers } }

      let(:expected_codes_and_responses) do
        Hash.new(code: 404)
      end

      it_behaves_like 'permissions for single object endpoint', ALL_PERMISSIONS
    end
  end
end

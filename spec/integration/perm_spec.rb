require 'spec_helper'
require 'perm'

RSpec.describe 'Perm', type: :integration, skip: ENV.fetch('CF_RUN_PERM_SPECS') { 'false' } != 'true' do
  include ControllerHelpers

  let(:org) { VCAP::CloudController::Organization.make }
  let(:assigner) { VCAP::CloudController::IsolationSegmentAssign.new }
  let(:user_email) { VCAP::CloudController::Sham.email }

  let(:perm_host) { ENV.fetch('PERM_RPC_HOST') { 'localhost:6283' } }
  let(:client) { CloudFoundry::Perm::V1::Client.new(perm_host) }

  before do
    TestConfig.config[:perm] = {
      enabled: true,
      host: perm_host
    }
  end

  describe 'PUT /v2/organizations/:guid/managers/:user_guid' do
    let(:org_manager) { VCAP::CloudController::User.make }

    context 'as an admin' do
      it 'assigns the specified user to the org manager role' do
        set_current_user_as_admin

        expect(client.list_actor_roles(org_manager.guid)).to be_empty

        put "/v2/organizations/#{org.guid}/managers/#{org_manager.guid}"
        expect(last_response.status).to eq(201)

        roles = client.list_actor_roles(org_manager.guid)
        expect(roles).not_to be_empty
        expect(roles[0].name).to eq "org-manager-#{org.guid}"
      end
    end
  end

  describe 'PUT /v2/organizations/:guid/auditors/:user_guid' do
    let(:org_auditor) { VCAP::CloudController::User.make }

    context 'as an admin' do
      it 'assigns the specified user to the org auditor role' do
        set_current_user_as_admin

        expect(client.list_actor_roles(org_auditor.guid)).to be_empty

        put "/v2/organizations/#{org.guid}/auditors/#{org_auditor.guid}"
        expect(last_response.status).to eq(201)

        roles = client.list_actor_roles(org_auditor.guid)
        expect(roles).not_to be_empty
        expect(roles[0].name).to eq "org-auditor-#{org.guid}"
      end
    end
  end

  describe 'PUT /v2/organizations/:guid/billing_managers/:user_guid' do
    let(:org_billing_manager) { VCAP::CloudController::User.make }

    context 'as an admin' do
      it 'assigns the specified user to the org billing manager role' do
        set_current_user_as_admin

        expect(client.list_actor_roles(org_billing_manager.guid)).to be_empty

        put "/v2/organizations/#{org.guid}/billing_managers/#{org_billing_manager.guid}"
        expect(last_response.status).to eq(201)

        roles = client.list_actor_roles(org_billing_manager.guid)
        expect(roles).not_to be_empty
        expect(roles[0].name).to eq "org-billing_manager-#{org.guid}"
      end
    end
  end

  describe 'PUT /v2/organizations/:guid/users/:user_guid' do
    let(:org_user) { VCAP::CloudController::User.make }

    context 'as an admin' do
      it 'assigns the specified user to the org billing manager role' do
        set_current_user_as_admin

        expect(client.list_actor_roles(org_user.guid)).to be_empty

        put "/v2/organizations/#{org.guid}/users/#{org_user.guid}"
        expect(last_response.status).to eq(201)

        roles = client.list_actor_roles(org_user.guid)
        expect(roles).not_to be_empty
        expect(roles[0].name).to eq "org-user-#{org.guid}"
      end
    end
  end
end

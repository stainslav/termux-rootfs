# Provides object graph for performing exports
RSpec.shared_context 'export objects' do
  #
  # Basics for testing export object itself
  #
  let(:workspace){ FactoryGirl.create(:mdm_workspace) }
  let(:host){ FactoryGirl.create(:mdm_host, workspace: workspace)}
  let(:service){ FactoryGirl.create(:mdm_service, host:host) }
  let(:origin) { FactoryGirl.create(:metasploit_credential_origin_import, task:nil) }
  let(:core){ FactoryGirl.create(:metasploit_credential_core, workspace: workspace, origin: origin) }
  let(:login){ FactoryGirl.create(:metasploit_credential_login, service: service, core:core) }


  #
  # Create 2 each of hosts, services, publics, privates, cores, and logins
  #
  let!(:host1){ FactoryGirl.create(:mdm_host, workspace: workspace) }
  let!(:host2){ FactoryGirl.create(:mdm_host, workspace: workspace) }

  let!(:service1){ FactoryGirl.create(:mdm_service, host: host1) }
  let!(:service2){ FactoryGirl.create(:mdm_service, host: host2) }

  let!(:public1){ FactoryGirl.create(:metasploit_credential_public) }
  let!(:public2){ FactoryGirl.create(:metasploit_credential_public) }

  let!(:private1){ FactoryGirl.create(:metasploit_credential_private, type: "Metasploit::Credential::Password") }
  let!(:private2){ FactoryGirl.create(:metasploit_credential_private, type: "Metasploit::Credential::Password") }

  let!(:core1){ FactoryGirl.create(:metasploit_credential_core,
                                  public: public1,
                                  private: private1,
                                  origin: origin,
                                  workspace: workspace) }

  let!(:core2){ FactoryGirl.create(:metasploit_credential_core,
                                  public: public2,
                                  private: private2,
                                  origin: origin,
                                  workspace: workspace) }

  let!(:login1){ FactoryGirl.create(:metasploit_credential_login, core: core1, service: service1) }
  let!(:login2){ FactoryGirl.create(:metasploit_credential_login, core: core2, service: service2) }

end
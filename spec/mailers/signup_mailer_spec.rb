require "spec_helper"

describe SignupMailer do
  describe "sendmail_activate" do
    let(:user) { create(:user, email: "gogooti@gmail.com") }
    let(:mail) { SignupMailer.sendmail_activate(user) }
    it "renders the headers" do
      mail.subject.should eq("Bookstrap登録確認")
      mail.to.should eq(["gogooti@gmail.com"])
      mail.from.should eq(["bookstrap.info@gmail.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("この度はBookstrapへユーザー登録を頂きまして")
    end
  end
end

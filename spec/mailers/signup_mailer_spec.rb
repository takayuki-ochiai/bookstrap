require "spec_helper"

describe SignupMailer do
  pending "メールテストはデフォルトのまま。これから作ります" do
  describe "sendmail_activate" do
    let(:mail) { SignupMailer.sendmail_activate }

    it "renders the headers" do
      mail.subject.should eq("Sendmail activate")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end
  end
end

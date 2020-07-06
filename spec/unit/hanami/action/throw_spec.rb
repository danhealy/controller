RSpec.describe Hanami::Action do
  describe ".handle_exception" do
    it "handle an exception with the given status" do
      response = HandledExceptionAction.new(configuration: configuration).call({})

      expect(response.status).to be(404)
    end

    it "raises the exception, if not handled" do
      expect { UnhandledExceptionAction.new(configuration: configuration).call({}) }.to raise_error(RecordNotFound)
    end

    describe "with global handled exceptions" do
      it "handles raised exception" do
        configuration = Hanami::Action::Configuration.new do |config|
          config.handle_exception DomainLogicException => 400
        end

        response = GlobalHandledExceptionAction.new(configuration: configuration).call({})

        expect(response.status).to be(400)
      end
    end
  end

  describe "#throw" do
    HTTP_TEST_STATUSES.each do |code, body|
      next if HTTP_TEST_STATUSES_WITHOUT_BODY.include?(code)

      it "throws an HTTP status code: #{code}" do
        response = ThrowCodeAction.new(configuration: configuration).call(status: code)

        expect(response.status).to be(code)
        expect(response.body).to eq([body])
      end
    end

    it "throws an HTTP status code with given message" do
      response = ThrowCodeAction.new(configuration: configuration).call(status: 401, message: "Secret Sauce")

      expect(response.status).to be(401)
      expect(response.body).to eq(["Secret Sauce"])
    end

    it "raises an exception when the code isn't valid" do
      expect { ThrowCodeAction.new(configuration: configuration).call(status: 2_131_231) }.to raise_error(StandardError)
    end

    it "stops execution of before filters (method)" do
      response = ThrowBeforeMethodAction.new(configuration: configuration).call({})

      expect(response.status).to be(401)
      expect(response.body).to eq(["Unauthorized"])
    end

    it "stops execution of before filters (block)" do
      response = ThrowBeforeBlockAction.new(configuration: configuration).call({})

      expect(response.status).to be(401)
      expect(response.body).to eq(["Unauthorized"])
    end

    it "stops execution of after filters (method)" do
      response = ThrowAfterMethodAction.new(configuration: configuration).call({})

      expect(response.status).to be(408)
      expect(response.body).to eq(["Request Timeout"])
    end

    it "stops execution of after filters (block)" do
      response = ThrowAfterBlockAction.new(configuration: configuration).call({})

      expect(response.status).to be(408)
      expect(response.body).to eq(["Request Timeout"])
    end
  end

  describe "using Kernel#throw in an action" do
    it "should work" do
      response = CatchAndThrowSymbolAction.new(configuration: configuration).call({})

      expect(response.status).to be(200)
    end
  end
end

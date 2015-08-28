class WelcomeController < ApplicationController

  def index
    agent = Mechanize.new
    agent.user_agent_alias = "Mac Safari"
    agent.add_auth('http://nagios.playrific.com/nagios/cgi-bin/status.cgi?host=all', 'angus', 'thomas8185.')
    agent.get('http://nagios.playrific.com/nagios/cgi-bin/status.cgi?host=all') do |page|
      @title = page.title
      @html = page.body
    end

    @doc = Nokogiri::HTML(@html)
    @statusOK = @doc.css('td.statusOK').count
    @statusCRITICAL = @doc.css('td.statusCRITICAL').count
    @statusWARNING = @doc.css('td.statusWARNING').count

    @messages = []
    @messagesCRITICAL = @doc.css('td.statusBGCRITICAL a').each do |message|
      @messages << message.inner_html
    end

    @messagesWARNING = @doc.css('td.statusBGWARNING a').each do |message|
      @host = @doc.xpath("//td[@class='statusBGWARNING']/a[text() = '#{message.inner_html}']/preceding::a[5]").text
      @messages << "#{@host}: #{message.inner_html}"
    end

    gon.statusOK = @statusOK
    gon.statusWARNING = @statusWARNING
    gon.statusCRITICAL = @statusCRITICAL

  end

end

# frozen_string_literal: true

class SiteMailer < ApplicationMailer
  def destroyed(email, site)
    @site = site
    mail(to: email, subject: "The team account for #{site.name} has been deleted")
  end

  def weekly_review(site, data, user)
    @site = site
    @data = data
    @unsubscribable = true

    return unless user.communication_enabled?(:weekly_review_email)

    mail(to: user.email, subject: 'Your Week In Review')
  end

  def plan_exceeded(site, data, user)
    @site = site
    @user = user
    @data = data

    mail(to: user.email, subject: "You've exceeded your monthly visit limit on #{site.name}")
  end

  def plan_nearing_limit(site, user)
    @site = site
    @user = user

    mail(to: user.email, subject: "You'll exceed your monthly visit limit soon for #{site.name}")
  end

  def new_feedback(data, user)
    @site = data[:site]
    @nps = data[:nps]
    @sentiment = data[:sentiment]

    return unless user.communication_enabled?(:feedback_email)

    mail(to: user.email, subject: "You've got new feedback from your visitors")
  end

  def tracking_code_instructions(site, first_name, email)
    @site = site
    @owner = site.owner.user
    @first_name = first_name

    @tracking_code = <<~HTML
      <!-- Squeaky Tracking Code for #{site.url} -->
      <script>
        (function(s,q,u,e,a,k,y){s._sqSettings={site_id:'#{@site.uuid}'};
          e=q.getElementsByTagName('head')[0];
          a=q.createElement('script');
          a.src=u+s._sqSettings.site_id;
          e.appendChild(a);
        })(window,document,'https://cdn.squeaky.ai/g/1.0.0/script.js?');
      </script>
    HTML

    mail(to: email, subject: "Your colleague #{@owner.full_name} needs your help")
  end
end

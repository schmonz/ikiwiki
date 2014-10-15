Feature: URL redirection
  As a person who publishes links intended to be "permanent"
  I want to know ASAP when they break
  So that I can act quickly to fix them

  Background:
    Given an ikiwiki site with the CGI enabled

  Scenario: Hard-coded redirect
    Given a browser
    When anyone hits the redirector
    Then it always redirects to the same site

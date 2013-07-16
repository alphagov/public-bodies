#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'csv'
require 'json'
require 'money'


class PublicBody
  attr_reader :department
  
  def cleanNumber(s)
    match = s.gsub(/,/, '').scan(/[0-9]+/)
    if match.empty?
      return 0
    end
    num = match.map{ |n| n.to_i }.reduce{ |n1, n2| n1 + n2 }
    return num / match.length
  end

  
  def formatMoney(n)
    Money.new(n * 100, "GBP").format(:no_cents_if_whole => true)
  end

  
  def cleanBool(s)
    return s.downcase == 'yes'
  end

  
  def cleanReform(s)
    if s.include? "Merge"
        return "merge"
    elsif s.include? "No longer an NDPB"
        return "abolish"
    elsif s.include? "Retain"
        return "retain"
    elsif s.include? "Under Consideration"
        return "under_consideration"
    else
      return "retain"
    end
  end

  
  def cleanClassification(s)
    if s.include? "Advisory"
      return 'advisory'
    elsif s.include? "Executive"
      return 'executive'
    elsif s.include? "Tribunal"
      return 'tribunal'
    else s.include? "Other"
      return 'other'
    end
  end

  
  def cleanWebsite(s)
    matches = s.scan(/(?:http:\/\/|www)(?:[a-zA-Z0-9\/\.]+)/)#find urls and split on them
    if matches.empty? #if we find no urls, return 'None', we can grab this later.
      url = 'None'
    else
      url = matches[0]
    end
    if url.start_with? 'http://' #Get things that start http and return them happily
      return url
    else
      return 'http://' + url #otherwise assume they're broken (government? https?) (seriously TODO fix this)'
    end
  end

  
  def webString(s)
    s.gsub(/[^\w ]/, '').downcase.gsub(/[ _]/, '-')#keep only numbers, i18n letters, underscores or spaces, lowercase the result and replace spaces and underscores with hyphens
  end

  def initialize(record)
    @_chairs_remuneration_pa_unless_otherwise_stated = record["Chair's Remuneration (PA unless otherwise stated)"]
    @_chief_executive_secretart_remuneration = record["Chief Executive / Secretart Remuneration"]
    @_count = record["Count"]
    @_government_funding = record["Government Funding"]
    @_multiple_bodies = record["Multiple Bodies"]
    @_ocpa_regulated = record["OCPA Regulated"]
    @_public_meetings = record["Public Meetings"]
    @_public_minutes = record["Public Minutes"]
    @_register_of_interests = record["Register of Interests"]
    @_regulatory_function = record["Regulatory Function"]
    @_staff_employed_fte = record["Staff Employed (FTE)"]
    @_total_gross_expenditure = record["Total Gross Expenditure"]
    @_classification = record["Classification"]

    @address = record["Address"]
    @audit_arrangements = record["Audit Arrangements"]
    @body_count = self.cleanNumber(@_count)
    @chair = record["Chair"]
    @chairs_remuneration = self.cleanNumber(@_chairs_remuneration_pa_unless_otherwise_stated)
    @chairs_remuneration_formatted = self.formatMoney(@chairs_remuneration)
    @chief_executive = record["Chief Executive / Secretary"]
    @chief_executive_remuneration = self.cleanNumber(@_chief_executive_secretart_remuneration)
    @chief_executive_remuneration_formatted = self.formatMoney(@chief_executive_remuneration)
    @classification = self.cleanClassification(@_classification)
    @clean_department = self.webString(record["Department"])
    @clean_name = self.webString(record["Name"])
    @department = record["Department"]
    @description = record["Description"]
    @email = record["email"]
    @government_funding = self.cleanNumber(@_government_funding)
    @government_funding_formatted = self.formatMoney(@government_funding)
    @last_annual_report = record["Last Annual Report"]
    @last_review = record["Last Review"]
    @name = record["Name"]
    @notes = record["Notes"]
    @ocpa_regulated = self.cleanBool(record["OCPA Regulated"])
    @ombudsman = record["Ombudsman"]
    @pb_reform = self.cleanReform(record["PB Reform"])
    @phone = record["Phone"]
    @public_meetings = self.cleanBool(@_public_meetings)
    @public_minutes = self.cleanBool(@_public_minutes)
    @register_of_interests = self.cleanBool(@_register_of_interests)
    @regulatory_function = self.cleanBool(@_regulatory_function)
    @staff_employed_fte = self.cleanNumber(@_staff_employed_fte)
    @total_gross_expenditure = self.cleanNumber(@_total_gross_expenditure)
    @total_gross_expenditure_formatted = self.formatMoney(@total_gross_expenditure)
    @website = self.cleanWebsite(record["Website"])
  end
  def to_hash
    return {
      "_chairs-remuneration-pa-unless-otherwise-stated" => @_chairs_remuneration_pa_unless_otherwise_stated,
      "_chief-executive-secretart-remuneration" => @_chief_executive_secretart_remuneration,
      "_count" => @_count,
      "_government-funding" => @_government_funding,
      "_multiple-bodies" => @_multiple_bodies,
      "_ocpa-regulated" => @_ocpa_regulated,
      "_public-meetings" => @_public_meetings,
      "_public-minutes" => @_public_minutes,
      "_register-of-interests" => @_register_of_interests,
      "_regulatory-function" => @_regulatory_function,
      "_staff-employed-fte" => @_staff_employed_fte,
      "_total-gross-expenditure" => @_total_gross_expenditure,
      "_classification" => @_classification,
      "address" => @address,
      "audit-arrangements" => @audit_arrangements,
      "body-count" => @body_count,
      "chair" => @chair,
      "chairs-remuneration" => @chairs_remuneration,
      "chairs-remuneration-formatted" => @chairs_remuneration_formatted,
      "chief-executive" => @chief_executive,
      "chief-executive-remuneration" => @chief_executive_remuneration,
      "chief-executive-remuneration-formatted" => @chief_executive_remuneration_formatted,
      "classification" => @classification,
      "clean-department" => @clean_department,
      "clean-name" => @clean_name,
      "department" => @department,
      "description" => @description,
      "email" => @email,
      "government-funding" => @government_funding,
      "government-funding-formatted" => @government_funding_formatted,
      "last-annual-report" => @last_annual_report,
      "last-review" => @last_review,
      "name" => @name,
      "notes" => @notes,
      "ocpa-regulated" => @ocpa_regulated,
      "ombudsman" => @ombudsman,
      "pb-reform" => @pb_reform,
      "phone" => @phone,
      "public-meetings" => @public_meetings,
      "public-minutes" => @public_minutes,
      "register-of-interests" => @register_of_interests,
      "regulatory-function" => @regulatory_function,
      "staff-employed-fte" => @staff_employed_fte,
      "total-gross-expenditure" => @total_gross_expenditure,
      "total-gross-expenditure-formatted" => @total_gross_expenditure_formatted,
      "website" => @website,
    }
  end
end

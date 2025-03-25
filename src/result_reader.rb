require "csv"
require "debug"

class ResultReader
  def read
    CSV.foreach("output/results.csv", headers: false) do |row|
      if unknown_issue?(row)
        write_to_results(row)
      end
    end
  end

  def write_to_results(row)
    CSV.open("output/filtered_results.csv", "a") do |csv|
      csv << row
    end
  end

  def unknown_issue?(row)
    return false if missing_loggable(row)
    return false if bad_note(row)
    return false if eco_ecr_multiple_migrators(row)
    return false if eco_changed_note_on_part_revision(row)
    return false if purchase_order(row)
    return false if eco_note_multiple_migrators(row)
    return false if eco_note_attr_multiple_migrators(row)
    return false if logbook_entry(row)
    return false if eco_note_approved_multiple_migrators(row)
    return false if eco_approved_attachment_multiple_migrators(row)
    return false if vault_lock_attr_multiple_migrators(row)
    return false if eco_note_closed_multiple_migrators(row)
    return false if purchase_approved_downloaded_multiple_migrators(row)
    return false if purchase_submitted_downloaded_multiple_migrators(row)
    return false if eco_thumbs_up_created_multiple_migrators(row)
    return false if revision_attachment_file_updated_multiple_migrators(row)
    return false if purchase_approved_attachment_added_multiple_migrators(row)
    return false if revision_attachment_added_file_updated_multiple_migrators(row)
    return false if site_part_number_settings(row)
    return false if purchase_submitted_attachment_multiple_migrators(row)
    return false if eco_url_added_by_file_updated_multiple_migrators(row)
    return false if site_removed_role(row)
    return false if revoked_quote_request(row)
    return false if quote_request_submitted(row)
    return false if purchase_buyer(row)

    true
  end

  def missing_loggable(row)
    result_message = row[3]
    row[1].nil? &&
      (
        result_message.include?("Created Unit") ||
        result_message.include?("Created Part") ||
        result_message.include?("Added a quote") ||
        result_message.include?("Removed a quote") ||
        result_message.include?("as an alternate part") ||
        result_message.include?("closed the quote request") ||
        result_message.include?("Created Manufacturer") ||
        result_message.include?("Created Contact") ||
        result_message.include?("Created Vendor") ||
        result_message.include?("Created Customer") ||
        result_message.include?("Added phone number") ||
        result_message.include?("Added address") ||
        result_message.include?("expressed position:") ||
        result_message.include?("re-opened the quote request") ||
        result_message.include?("changed the note on affected part") ||
        result_message.include?("created the ECO.") ||
        result_message.include?("created the ECR") ||
        result_message.include?("revoked the purchase for approval") ||
        result_message.include?("approved the quote request") ||
        result_message.include?("created the purchase") ||
        result_message.include?("submitted the purchase for approval") ||
        result_message.include?("Purchase buyer changed from") ||
        result_message.include?("Released revision") ||
        result_message.include?("Created revision") ||
        result_message.include?("withdrew the ECR") ||
        result_message.include?("Added safety stock targets") ||
        result_message.include?("re-drafted the ECR") ||
        result_message.include?("approved the ECR") ||
        result_message.include?("approved the ECO") ||
        result_message.include?("Destroyed Customer") ||
        result_message.include?("Removed phone number") ||
        result_message.include?("Updated phone number") ||
        result_message.include?("Updated address") ||
        result_message.include?("Removed address") ||
        result_message.include?("Destroyed revision") ||
        result_message.include?("revoked the ECR for approval") ||
        result_message.include?("revoked the ECO for approval") ||
        result_message.include?("submitted the quote request for approval") ||
        result_message.include?("Destroyed Part") ||
        purchase_order_submitted(row) ||
        result_message.include?("approved the purchase")
      )
  end

  def site_part_number_settings(row)
    row[3].include?("updated part number settings")
  end

  def purchase_buyer(row)
    row[3].include?("Purchase buyer changed from")
  end

  def revoked_quote_request(row)
    row[3].include?("revoked the quote request for approval")
  end

  def site_removed_role(row)
    row[3].include?("removed a role")
  end

  def quote_request_submitted(row)
    result_message = row[3]
    result_message.include?("Quote request to") &&
      result_message.include?("was marked as submitted.")
  end

  def purchase_order(row)
    result_message = row[3]
    result_message.include?("Created PurchaseOrder") ||
      result_message.include?("Destroyed PurchaseOrder")
  end

  def purchase_order_submitted(row)
    result_message = row[3]
    result_message.include?("Purchase order to ") &&
      result_message.include?("was marked as submitted")
  end

  def logbook_entry(row)
    result_message = row[3]
    result_message.include?("submitted the logbook entry for approval") ||
      result_message.include?("rejected the logbook entry") ||
      result_message.include?("approved the logbook entry") ||
      result_message.include?("revoked the logbook entry for approval")
  end

  def bad_note(row)
    row[3].include?("Removed Note")
  end

  def eco_ecr_multiple_migrators(row)
    ecr_multiple_migrators(row) || eco_multiple_migrators(row)
  end

  def ecr_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeRequestThumbsUp") &&
      result_message.include?("EngineeringChangeRequestApproved")
  end

  def eco_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeOrderThumbsUp") &&
      result_message.include?("EngineeringChangeOrderApproved")
  end

  def eco_note_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeOrderNoteUpdated") &&
      result_message.include?("EngineeringChangeOrderCreated")
  end

  def eco_note_attr_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeOrderNoteUpdated") &&
      result_message.include?("AttributeChanged")
  end

  def eco_note_approved_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeOrderNoteUpdated") &&
      result_message.include?("EngineeringChangeOrderApproved")
  end

  def eco_approved_attachment_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeOrderApproved") &&
      result_message.include?("AttachmentAdded")
  end

  def eco_note_closed_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeOrderNoteUpdated") &&
      result_message.include?("EngineeringChangeOrderClosed")
  end

  def eco_thumbs_up_created_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("EngineeringChangeOrderThumbsUp") &&
      result_message.include?("EngineeringChangeOrderCreated")
  end

  def eco_url_added_by_file_updated_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("FileUpdated") &&
      result_message.include?("UrlAddedBy")
  end

  def vault_lock_attr_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("VaultLocked") &&
      result_message.include?("AttributeChanged")
  end

  def purchase_approved_downloaded_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("PurchaseApproved") &&
      result_message.include?("Downloaded")
  end

  def purchase_approved_attachment_added_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("PurchaseApproved") &&
      result_message.include?("AttachmentAdded")
  end

  def purchase_submitted_downloaded_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("PurchaseSubmitted") &&
      result_message.include?("Downloaded")
  end

  def purchase_submitted_attachment_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("PurchaseSubmitted") &&
      result_message.include?("AttachmentAdded")
  end

  def revision_attachment_file_updated_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("AttachmentRemoved") &&
      result_message.include?("FileUpdated")
  end

  def revision_attachment_added_file_updated_multiple_migrators(row)
    result_message = row[4]
    result_message.include?("AttachmentAdded") &&
      result_message.include?("FileUpdated")
  end

  def eco_changed_note_on_part_revision(row)
    row[4].include?("changed the note on part revision")
  end
end

ResultReader.new.read

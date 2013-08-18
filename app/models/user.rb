class User < ActiveRecord::Base
  has_secure_password
  validates_uniqueness_of :email
  validates_length_of :password, :minimum => 6

  has_many :sent_messages, :class_name => "Message", :foreign_key => :sender_id
  has_many :received_messages, :class_name => "Message", :foreign_key => :receiver_id

  has_many :starter_conversations, :class_name => "Conversation", :foreign_key => :starter_user_id
  has_many :received_conversations, :class_name => "Conversation", :foreign_key => :with_user_id

  def conversations
    Conversation.where("starter_user_id = ? OR with_user_id = ?", self.id, self.id).order("created_at DESC")
  end

  def new_messages_count
    self.received_messages.where("read_at IS NULL").count
  end

  def can_start_new_conversation_with?(user_id)
    !has_active_conversation_with?(user_id)
  end

  def has_active_conversation_with?(user_id)
    !current_active_conversation_with(user_id).blank?
  end


  def current_active_conversation_with(user_id)
    self.starter_conversations.where(:with_user_id => user_id).first || self.received_conversations.where(:starter_user_id => user_id).first
  end

end

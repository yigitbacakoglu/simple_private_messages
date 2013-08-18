class ConversationsController < ApplicationController

  before_action :authorize, :only => [:show, :edit, :update]

  before_action :set_conversation, :except => [:index, :new, :create, :delete_conversations]

  def index

  end

  def show
    @conversation.read!(current_user)
  end

  def new
    redirect_to conversations_path and return if params[:with].blank?
    if current_user.has_active_conversation_with?(params[:with])
      redirect_to conversation_path(current_user.current_active_conversation_with(params[:with])) and return
    else
      @conversation = current_user.starter_conversations.build(:with_user_id => params[:with])
      @conversation.messages.build(:sender_id => current_user.id, :receiver_id => params[:with])
    end
  end

  def create

    if !(@conversation = current_user.current_active_conversation_with(params[:with])).blank?
      message = @conversation.messages.new(params[:conversation][:messages_attributes].permit!)
      message.sender_id = current_user.id
    else
      @conversation = current_user.starter_conversations.new(params[:conversation].permit!)
      #Double check for hack attempts
      @conversation.messages.each do |m|
        m.sender_id = current_user.id
      end
    end

    if  @conversation.save
      redirect_to conversation_path(@conversation)
    else
      render "new"
    end

  end

  def new_message
    if @conversation.messages.create(:body => params[:body], :sender_id => current_user.id, :receiver_id => @conversation.target_for(current_user).id)
      flash[:notice] = "Successfully send"
    else
      flash[:notice] = "Couldn't send message"
    end
    redirect_to conversation_path(@conversation)
  end

  def delete_messages
    @conversation.messages.where(:id => params[:message_ids]).each do |message|
      message.delete_for(current_user)
    end
    redirect_to conversation_path(@conversation)
  end

  def delete_conversations
    Message.where(:conversation_id => params[:conversation_ids]).each do |message|
      message.delete_for(current_user)
    end
    redirect_to conversations_path
  end

  private

  def set_conversation
    @conversation = Conversation.user_scoped(current_user).where(:id => params[:id]).first
  end

end
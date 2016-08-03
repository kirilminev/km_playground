public with sharing class ChatterUtils {

Public Static void createObjectChatterFeed (String feedBody, String parentId, String mentionUserID) {
	ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
         ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
         ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
         ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
         messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
         textSegmentInput.text = feedBody;
         messageBodyInput.messageSegments.add(textSegmentInput);

         mentionSegmentInput.id = mentionUserID; 
         messageBodyInput.messageSegments.add(mentionSegmentInput);

         feedItemInput.body = messageBodyInput;
         feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

         feedItemInput.subjectId = parentId ; 
         ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput, null);
     }
}
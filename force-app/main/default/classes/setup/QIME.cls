global class QIME {
  @TestVisible
  private static final String CURRENT_VERSION_NUMBER = 'v4.20.0';

  /**
   * @description Returns the current version number of QIME
   * @return The current version number, in the format `v0.0.0`
   */
  global static String getVersionNumber() {
    return CURRENT_VERSION_NUMBER;
  }

  global static String getSessionIdFromVFPage(PageReference visualforcePage) {
    String content = visualforcePage.getContent().toString();
    System.debug(content);
    return content;
  }

  public class SessionId {
    public String sessionId;
  }

  public static List<qime__QIME_Config__mdt> getConfig() {
    if (Test.isRunningTest()) {
      return new List<qime__QIME_Config__mdt>{ QBTestHelper.getConfig() };
    }
    return [
      SELECT
        Id,
        qime__Create_Invoice_From_Opp__c,
        qime__Create_Customer_w_Invoice__c,
        qime__Invoice_Stage_Name__c,
        qime__Custom_Field_1_Id__c,
        qime__Custom_Field_2_Id__c,
        qime__Custom_Field_3_Id__c
      FROM qime__QIME_Config__mdt
      LIMIT 1
    ];
  }
}

global class QBSalesReceiptQueueable implements Queueable, Database.AllowsCallouts {
  Integer currentCount;
  Integer totalCount;
  Integer iteratorSize;
  Integer stackDepth;
  global QBSalesReceiptQueueable(
    Integer currentCount,
    Integer totalCount,
    Integer iteratorSize,
    Integer stackDepth
  ) {
    this.currentCount = currentCount;
    this.totalCount = totalCount;
    this.iteratorSize = iteratorSize;
    this.stackDepth = stackDepth;
  }

  global void execute(QueueableContext context) {
    if (totalCount == 0) {
      totalCount = QBMap.getCount(QBCallout.getSalesReceiptCount());
    }
    String query = 'select * from SalesReceipt ';
    if (QIMEParameter.SALES_RECEIPT_SYNC_START != null) {
      query +=
        'WHERE Metadata.LastUpdatedTime > \'' +
        QIMEParameter.SALES_RECEIPT_SYNC_START.formatGmt(
          'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''
        ) +
        '\'';
    }

    if (QIMEParameter.SALES_RECEIPT_SYNC_END != null) {
      if (QIMEParameter.SALES_RECEIPT_SYNC_START != null) {
        query += ' AND ';
      } else {
        query += ' WHERE ';
      }
      query +=
        ' Metadata.LastUpdatedTime < \'' +
        QIMEParameter.SALES_RECEIPT_SYNC_END.formatGmt(
          'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''
        ) +
        '\'';
    }

    query +=
      ' MAXRESULTS ' +
      String.valueOf(this.iteratorSize) +
      ' STARTPOSITION ' +
      String.valueOf(this.currentCount);

    List<SObject> returnList = QBSalesReceiptHelper.getSalesReceipts(query);
    QBSalesReceiptHelper.updateObjects(returnList);

    this.currentCount += this.iteratorSize;
    if (this.currentCount < this.totalCount) {
      System.enqueueJob(
        new QBSalesReceiptQueueable(
          currentCount,
          totalCount,
          iteratorSize,
          stackDepth++
        )
      );
    }
  }
}

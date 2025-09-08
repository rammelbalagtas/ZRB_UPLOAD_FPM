@EndUserText.label: 'Excel Popup'
define abstract entity ZABS_VENDOR
{
  @Semantics.largeObject:
               { mimeType : 'MimeType',
                 fileName: 'FileName',
                 acceptableMimeTypes: [ 'text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
                 contentDispositionPreference: #INLINE }
  Attachment : abap.rawstring( 0 );
  @Semantics.mimeType: true
  MimeType   : abap.string( 0 );
  FileName   : abap.string( 0 );
  TestRun    : abap.string( 0 );
}

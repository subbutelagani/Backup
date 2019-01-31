<?xml version="1.0" encoding="UTF-8"?>
<!-- +======================================================================+ -->
<!-- |    Copyright (c) 2005, 2013 Oracle and/or its affiliates.           | -->
<!-- |                         All rights reserved.                         | -->
#<!-- |                           Version 12.0.0                             | -->
<!-- +======================================================================+ -->
<!--  $Header: IBY_ISO_CT_CORE_V3_USTD.xsl 120.0.12010000.3 2013/11/07 17:02:15 sgogula noship $   --> 
<!--  dbdrv: exec java oracle/apps/xdo/oa/util XDOLoader.class java &phase=dat checkfile:~PROD:patch/115/publisher/templates:IBY_ISO_CT_CORE_V3_USTD.xsl UPLOAD -DB_USERNAME &un_apps -DB_PASSWORD &pw_apps -JDBC_CONNECTION &jdbc_db_addr -LOB_TYPE TEMPLATE -APPS_SHORT_NAME IBY -LOB_CODE IBY_ISO_CT_001.001.03_USTRD -LANGUAGE en -XDO_FILE_TYPE XSL-XML -FILE_NAME &fullpath:~PROD:patch/115/publisher/templates:IBY_ISO_CT_CORE_V3_USTD.xsl -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output omit-xml-declaration="no"/>
<xsl:output method="xml"/>
<xsl:key name="contacts-by-LogicalGroupReference" match="OutboundPayment" use="PaymentNumber/LogicalGroupReference" />
<xsl:template match="OutboundPaymentInstruction">
	<xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="instrid" select="PaymentInstructionInfo/InstructionReferenceNumber"/>
	
		 
		<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

			<CstmrCdtTrfInitn>
				<GrpHdr>
					<MsgId>
						<xsl:value-of select="$instrid"/>
					</MsgId>
					<CreDtTm>
						<xsl:value-of select="PaymentInstructionInfo/InstructionCreationDate"/>
					</CreDtTm>

					<NbOfTxs>
						<xsl:value-of select="InstructionTotals/PaymentCount"/>
					</NbOfTxs>
					<CtrlSum>
						<xsl:value-of
							select="format-number(sum(OutboundPayment/PaymentAmount/Value), '##0.00')"/>
					</CtrlSum>
					<InitgPty>
						<Nm>
							<xsl:choose>
								<xsl:when
									test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_NAME'])=0) and not(translate(PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_NAME']/Value,$lower,$upper) = 'NA') ">
									<xsl:value-of
										select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_NAME']/Value"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="InstructionGrouping/Payer/LegalEntityName"/>
								</xsl:otherwise>
							</xsl:choose>
						</Nm>
						<Id>
							<OrgId>
                                                              <Othr>
                                                                    <Id>EMRTIE2O</Id>
                                                                   <!-- <SchmeNm>
                                                                           <Cd>CUST</Cd>
                                                                    </SchmeNm>-->
                                                              </Othr>
                                                        </OrgId>			
						</Id>
					</InitgPty>
				</GrpHdr>

				<xsl:for-each
					select="OutboundPayment[count(. | key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)[1]) = 1]">
					<xsl:sort select="PaymentNumber/LogicalGroupReference"/>

					<PmtInf>
                                                <PmtInfId>
                                                        <xsl:value-of select="PaymentNumber/PaymentReferenceNumber"/>
                                                </PmtInfId>
						<PmtMtd>TRF</PmtMtd>
						<NbOfTxs>
							<xsl:value-of
								select="count(key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference))"/>
						</NbOfTxs>
						<CtrlSum>
							<xsl:value-of
								select="format-number(sum(key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)/PaymentAmount/Value),'#.00')"/>
						</CtrlSum>
						<PmtTpInf>
								<SvcLvl>
									<Cd>
									<xsl:choose>
									<xsl:when test="(PaymentMethod/PaymentMethodFormatValue='ACHDOM')">NURG</xsl:when>
									<xsl:when test="(PaymentMethod/PaymentMethodFormatValue='WIREDOM')">URGP</xsl:when>
									<xsl:when test="(PaymentMethod/PaymentMethodFormatValue='WIREINTL')">URGP</xsl:when>
							        <xsl:otherwise>NURG</xsl:otherwise>
									</xsl:choose>
									</Cd>
								</SvcLvl>
							<!--	<xsl:if test="(PaymentMethod/PaymentMethodFormatValue='ACHDOM')">
                                                                <LclInstrm> 
                                                                        <Cd>CCD</Cd> 
                                                                 </LclInstrm>
							     </xsl:if>	-->								 
						</PmtTpInf>

						<ReqdExctnDt>
							<xsl:value-of select="PaymentDate"/>
						</ReqdExctnDt>

						<Dbtr>
							<Nm>
								<xsl:choose>
								<xsl:when
									test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME'])=0) and not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value,$lower,$upper) = 'NA') ">
									<xsl:value-of
										select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value"/>
								</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="Payer/Name"/>
									</xsl:otherwise>
								</xsl:choose>
							</Nm>

							<PstlAdr>
								<StrtNm>
									<xsl:value-of select="Payer/Address/AddressLine1"/>
								</StrtNm>
								<xsl:if test="not(Payer/Address/PostalCode='')">
								<PstCd>
									<xsl:value-of select="Payer/Address/PostalCode"/>
								</PstCd>
								</xsl:if>
								<xsl:if test="not(Payer/Address/City='')">
								<TwnNm>
									<xsl:value-of select="Payer/Address/City"/>
								</TwnNm>
								</xsl:if>
								<!-- <xsl:if
									test="not(Payer/Address/State='') or not(Payer/Address/Province='')">
									<CtrySubDvsn>
										<xsl:value-of select="Payer/Address/State"/>
										<xsl:value-of select="Payer/Address/Province"/>
									</CtrySubDvsn>
								</xsl:if> -->	
								<xsl:if test="not(Payer/Address/Country='')">
									<Ctry>
										<xsl:value-of select="Payer/Address/Country"/>
									</Ctry>
								</xsl:if>
							</PstlAdr>
							        <!--     <xsl:if test="(PaymentMethod/PaymentMethodFormatValue='ACHDOM')">
                                                        <Id> 
                                                             <OrgId> 
                                                                 <Othr> 
                                                                          <Id>6760406982</Id> 
                                                                            <SchmeNm> 
                                                                                               <Cd>CHID</Cd> 
                                                                            </SchmeNm> 
                                                                   </Othr> 
                                                             </OrgId> 
                                                        </Id> 
										</xsl:if>				
                                                        <CtryOfRes>US</CtryOfRes>	-->				
						</Dbtr>
						<DbtrAcct>
						  	<Id>
								<!--<xsl:if test="not(BankAccount/IBANNumber='')">
									<IBAN>
										<xsl:value-of select="BankAccount/IBANNumber"/>
									</IBAN>
								</xsl:if>
								 if no IBAN, use bank account number-->
								<!--<xsl:if test="(BankAccount/IBANNumber='')">-->
									<Othr>
										<Id>
											<xsl:value-of select="BankAccount/BankAccountNumber"/>
										</Id>
									</Othr>
								<!--</xsl:if> -->
							</Id>
							
							<Ccy>
								<xsl:value-of select="BankAccount/BankAccountCurrency/Code"/>
							</Ccy>
						</DbtrAcct>

						<DbtrAgt>
							<FinInstnId>
							<BIC>CITIILITXXX</BIC>
                                                            <!--    <ClrSysMmbId>
                                                                        <ClrSysId>
                                                                                <Cd>USABA</Cd>
                                                                        </ClrSysId>
                                                                     <MmbId>
																		<xsl:choose><xsl:when test="(PaymentMethod/PaymentMethodFormatValue='ACHDOM')">
																		<xsl:value-of select="BankAccount/AlternateBranchName"/>
																		</xsl:when>
									                                    <xsl:otherwise>
																		<xsl:value-of select="BankAccount/BranchNumber"/>
																		</xsl:otherwise>
									                                     </xsl:choose>
																	</MmbId>
                                                                </ClrSysMmbId>-->
								<PstlAdr>
									<Ctry>
										<xsl:value-of select="BankAccount/BankAddress/Country"/>
									</Ctry>
								</PstlAdr>
							</FinInstnId>														                                                     
						</DbtrAgt>

						<xsl:for-each
							select="key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)">
							<CdtTrfTxInf>
								<xsl:variable name="paymentdetails" select="PaymentDetails"/>
								<PmtId>	
                                                                        <InstrId>
                                                                            <xsl:value-of select="PaymentNumber/CheckNumber"/>
                                                                        </InstrId>								
									<EndToEndId>
										<xsl:value-of select="PaymentNumber/CheckNumber"/>
									</EndToEndId>
								</PmtId>
                                            
								<Amt>
									<InstdAmt>

										<xsl:attribute name="Ccy">
											<xsl:value-of select="PaymentAmount/Currency/Code"/>
										</xsl:attribute>

										<xsl:value-of
											select="format-number(PaymentAmount/Value,'#.00')"/>

									</InstdAmt>

								</Amt>

								<ChrgBr>DEBT</ChrgBr>
									
								<CdtrAgt>
									<FinInstnId>	
                                        <xsl:if test="not(PayeeBankAccount/SwiftCode='') and (PaymentMethod/PaymentMethodFormatValue='WIREINTL')">	
										  <BIC>
										  <!--<xsl:value-of select="PayeeBankAccount/SwiftCode"/>-->
										  <xsl:value-of select="translate(PayeeBankAccount/SwiftCode, $lower, $upper)" />
										  </BIC>
                                        </xsl:if>										
										<!--xsl:if test="(PayeeBankAccount/SwiftCode='')"-->
											<xsl:if test="not(PayeeBankAccount/BranchNumber='') and not(PaymentMethod/PaymentMethodFormatValue='WIREINTL')">
												<ClrSysMmbId>
                                                                                                  <!--      <ClrSysId>
                                                                                                                <Cd>USABA</Cd>
                                                                                                        </ClrSysId>-->
												        <MmbId>
														  <!--  <xsl:if test="(string-length(PayeeBankAccount/BranchNumber) &lt; 5)">
												                <xsl:value-of select="concat('000',PayeeBankAccount/BranchNumber)"/>
														  <xsl:value-of select="PayeeBankAccount/BranchNumber"/>
															</xsl:if> 
															<xsl:if test="(string-length(PayeeBankAccount/BranchNumber) &gt; 4)">
															<xsl:value-of select="PayeeBankAccount/BranchNumber"/>
															</xsl:if>-->
														  <xsl:choose>
														          <xsl:when test="(string-length(PayeeBankAccount/BranchNumber) = 1)">
																  <xsl:value-of select="concat(PayeeBankAccount/BankNumber,'00',PayeeBankAccount/BranchNumber)"/>
															      </xsl:when>
                                                                  <xsl:when test="(string-length(PayeeBankAccount/BranchNumber) = 2)">
																  <xsl:value-of select="concat(PayeeBankAccount/BankNumber,'0',PayeeBankAccount/BranchNumber)"/>
															      </xsl:when>
                                                               <xsl:otherwise>
																<xsl:value-of select="concat(PayeeBankAccount/BankNumber,PayeeBankAccount/BranchNumber)"/>
															  </xsl:otherwise>
														</xsl:choose>
												        </MmbId>
												</ClrSysMmbId>
											</xsl:if>
										<!--/xsl:if-->
										<xsl:if test="not(PayeeBankAccount/BankName='')">
											<Nm>
												<xsl:value-of select="PayeeBankAccount/BankName"/>
											</Nm>
										</xsl:if>
										<PstlAdr>
												<Ctry>
												<xsl:value-of select="PayeeBankAccount/BankAddress/Country"/>
												</Ctry>
										</PstlAdr>
									</FinInstnId>									
								</CdtrAgt>

								<Cdtr>
									<xsl:if test="not(PayeeBankAccount/BankAccountName='')">
										<Nm>
									<xsl:choose>
									<xsl:when test="(PaymentMethod/PaymentMethodFormatValue='ACHDOM')">
									<xsl:value-of select="substring(PayeeBankAccount/BankAccountName,1,16)"/>
									</xsl:when>
							        <xsl:otherwise>
									<xsl:value-of select="PayeeBankAccount/BankAccountName"/>
									</xsl:otherwise>
									</xsl:choose>
                                         </Nm>
									</xsl:if>
									<PstlAdr>
									   <xsl:if test="not(Payee/Address/AddressLine1='')">
										<StrtNm>
											<xsl:value-of select="Payee/Address/AddressLine1"/>
										</StrtNm>
										</xsl:if>
										<xsl:if test="not(Payee/Address/PostalCode='')">
										<PstCd>
											<xsl:value-of select="Payee/Address/PostalCode"/>
										</PstCd>
										</xsl:if>
                                      <xsl:if test="not(Payee/Address/City='')">
										<TwnNm>
											<xsl:value-of select="Payee/Address/City"/>
										</TwnNm>
									  </xsl:if>	
										<!--<xsl:if
											test="not(Payee/Address/County='') or not(Payee/Address/State='') or not(Payee/Address/Province='')">
											<CtrySubDvsn>
												<xsl:value-of select="Payee/Address/County"/>
												<xsl:value-of select="Payee/Address/State"/>
												<xsl:value-of select="Payee/Address/Province"/>
											</CtrySubDvsn>
										</xsl:if>-->
										<Ctry>
											<xsl:value-of select="Payee/Address/Country"/>
										</Ctry>
									</PstlAdr>
								</Cdtr>


								<CdtrAcct>
									<Id>
										<xsl:if test="not(PayeeBankAccount/IBANNumber='')">
											<IBAN>
												<xsl:value-of select="PayeeBankAccount/IBANNumber"/>
											</IBAN>
										</xsl:if>
										<!-- if no IBAN, use bank account number-->
										<xsl:if test="(PayeeBankAccount/IBANNumber='')">
											<Othr>
												<Id>
												<xsl:value-of
												select="PayeeBankAccount/UserEnteredBankAccountNumber"/>
												</Id>
											</Othr>
										</xsl:if>
									</Id>

									<xsl:if test="not(PayeeBankAccount/BankAccountName='')">
										<Nm>
											<xsl:value-of select="PayeeBankAccount/BankAccountName"/>
										</Nm>
									</xsl:if>
								</CdtrAcct>
								<InstrForCdtrAgt>
								  <InstrInf>
								   <xsl:choose>
									<xsl:when test="(PaymentMethod/PaymentMethodFormatValue='ACHDOM')">/ILTE/006</xsl:when>
									<xsl:when test="(PaymentMethod/PaymentMethodFormatValue='WIREDOM')">/ILTE/006</xsl:when>
							        <xsl:otherwise>
									<xsl:value-of select="PaymentNumber/CheckNumber"/>
									</xsl:otherwise>
									</xsl:choose>
								  </InstrInf>
								  </InstrForCdtrAgt>
                                                              <!--  <InstrForCdtrAgt>
                                                                        <InstrInf>
                                                                                <xsl:value-of select="PaymentNumber/CheckNumber"/>
                                                                        </InstrInf>
                                                                </InstrForCdtrAgt>-->
					             <xsl:if test="(PaymentMethod/PaymentMethodFormatValue='WIREINTL')">												
											  <RgltryRptg>
												<Dtls>
												<Cd>
												<xsl:choose>
												<xsl:when test="(Payee/Address/Country='IL')">382</xsl:when>
												<xsl:otherwise>300</xsl:otherwise>
												</xsl:choose>
												</Cd> 
												</Dtls>
												</RgltryRptg>
								</xsl:if>				
										<xsl:if test="(PaymentMethod/PaymentMethodFormatValue='WIREINTL')">		
										    <Tax>
											<Rcrd>
											  <AddtlInf>Yes - I declare tax</AddtlInf> 
											 </Rcrd>
											</Tax>
		                                 </xsl:if>
										<!-- <RmtInf>
											<Ustrd>Yes - I declare tax</Ustrd>
											</RmtInf> -->
							
							</CdtTrfTxInf>
						</xsl:for-each>
					</PmtInf>
				</xsl:for-each>
			</CstmrCdtTrfInitn>
		</Document>
	</xsl:template>
</xsl:stylesheet>

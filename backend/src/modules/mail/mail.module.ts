import { Module, Global } from '@nestjs/common';
import { MailerModule } from '@nestjs-modules/mailer';
import { AppConfigService } from '@/config/app-config.service';

@Global()
@Module({
  imports: [
    MailerModule.forRootAsync({
      inject: [AppConfigService],
      useFactory: (config: AppConfigService) => ({
        transport: {
          host: config.mail.host,
          port: config.mail.port,
          secure: config.mail.encryption === 'ssl',
          auth: {
            user: config.mail.username,
            pass: config.mail.password,
          },
          tls: {
            rejectUnauthorized: false,
          },
        },
        defaults: {
          from: `"${config.mail.fromName}" <${config.mail.fromAddress}>`,
        },
      }),
    }),
  ],
  exports: [MailerModule],
})
export class MailModule {}

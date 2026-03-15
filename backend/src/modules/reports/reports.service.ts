import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { MailerService } from '@nestjs-modules/mailer';

@Injectable()
export class ReportsService {
  constructor(private readonly mailerService: MailerService) {}

  async sendUsageReport(reportData: any) {
    try {
      const totalMs = reportData.total_ms || 0;
      const formattedTotal = this.formatDuration(totalMs);

      const apps = ['facebook', 'youtube', 'instagram', 'whatsapp'];
      let appDetailsHtml = '';

      apps.forEach((app) => {
        const data = reportData[app] || {};
        const ms = data.ms || 0;
        const count = data.count || 0;
        appDetailsHtml += `
          <div style="margin-bottom: 20px; padding: 15px; background: #f4f4f4; border-radius: 8px;">
            <h3 style="margin: 0 0 10px 0; color: #333; text-transform: capitalize;">${app}</h3>
            <p style="margin: 5px 0;"><strong>Time Spent:</strong> ${this.formatDuration(ms)}</p>
            <p style="margin: 5px 0;"><strong>Launch Count:</strong> ${count}</p>
          </div>
        `;
      });

      await this.mailerService.sendMail({
        to: 'city.abdullah165608@gmail.com',
        subject: `DeenGuard Usage Report - ${new Date().toLocaleDateString()}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #444;">
            <h1 style="color: #00E676; border-bottom: 2px solid #00E676; padding-bottom: 10px;">DeenGuard Usage Report</h1>
            <p style="font-size: 18px;"><strong>Total Screen Time Today:</strong> ${formattedTotal}</p>
            
            <h2 style="margin-top: 30px; color: #555;">App Breakdown</h2>
            ${appDetailsHtml}
            
            <p style="margin-top: 40px; font-size: 12px; color: #888; border-top: 1px solid #eee; padding-top: 10px;">
              This report was generated automatically by DeenGuard.
            </p>
          </div>
        `,
      });

      return { success: true, message: 'Report sent successfully' };
    } catch (error) {
      console.error('Error sending report email:', error);
      throw new InternalServerErrorException('Failed to send report email');
    }
  }

  private formatDuration(ms: number) {
    if (ms <= 0) return '0m';
    const totalMinutes = Math.floor(ms / 60000);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;

    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
  }
}

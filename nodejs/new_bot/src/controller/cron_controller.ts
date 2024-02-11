import cron from 'node-cron';

export class CronController {
    private cronTime: string = '* * * * *';
    private task: () => void = () => {
        console.log(`Task executed at ${new Date()}`);
    };
    private scheduleTask = () => {
        return cron.schedule(this.cronTime, this.task, { scheduled: false });
    };

    public startTask() {
        this.scheduleTask().start();
    }

    public stopTask() {
        this.scheduleTask().stop();
    }
}